import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/storage/secure_token_storage.dart';
import '../models/platform_user.dart';
import '../services/platform_auth_service.dart';

enum PlatformAuthStatus { initializing, locked, authenticated, unauthenticated }

class PlatformAuthController extends ChangeNotifier {
  PlatformAuthController._();

  static final PlatformAuthController instance = PlatformAuthController._();

  final PlatformAuthService _service = PlatformAuthService();

  final SecureTokenStorage _storage = SecureTokenStorage.instance;

  PlatformAuthStatus _status = PlatformAuthStatus.initializing;

  PlatformUser? _user;

  String? _errorMessage;

  PlatformAuthStatus get status => _status;

  PlatformUser? get user => _user;

  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _status == PlatformAuthStatus.authenticated;

  // --------------------------------------------------
  // INITIALIZE / RESTORE SESSION
  // --------------------------------------------------

  Future<void> initialize() async {
    try {
      final rememberMe = await _storage.shouldRememberMe();
      if (!rememberMe) {
        await _storage.clearTokens();
        _setUnauthenticated();
        return;
      }

      final deviceKey = await _storage.getTrustedDeviceKey();
      final refreshToken = await _storage.getRefreshToken();
      if (deviceKey == null || refreshToken == null) {
        await _storage.clearTokens();
        _setUnauthenticated();
        return;
      }

      _user = null;
      _status = PlatformAuthStatus.locked;
      notifyListeners();
    } catch (_) {
      await _storage.clearTokens();
      _setUnauthenticated();
    }
  }

  // --------------------------------------------------
  // LOGIN
  // --------------------------------------------------

  Future<void> signIn({
    required String email,
    required String password,
    bool deferAuthentication = false,
  }) async {
    _errorMessage = null;

    try {
      final response = await _service.login(email: email, password: password);

      final accessToken = response['accessToken'];
      final refreshToken = response['refreshToken'];

      if (accessToken is! String || refreshToken is! String) {
        throw Exception('The server returned an invalid login response.');
      }

      await _storage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        rememberMe: false,
      );

      await _loadAndVerifyProfile(
        accessToken,
        activate: !deferAuthentication,
      );
    } catch (error) {
      await _storage.clearTokens();

      _errorMessage = _cleanError(error);

      _setUnauthenticated();

      rethrow;
    }
  }

  void completeSignIn() {
    if (_user == null) {
      throw StateError('Sign-in has not been verified.');
    }
    _status = PlatformAuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> rememberCurrentDevice(
    String pin, {
    bool enableBiometrics = false,
  }) async {
    final accessToken = await _storage.getAccessToken();
    if (accessToken == null) {
      throw Exception('Your login session is no longer available.');
    }

    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    final deviceKey = base64UrlEncode(bytes).replaceAll('=', '');

    await _service.rememberDevice(
      accessToken: accessToken,
      deviceKey: deviceKey,
      pin: pin,
    );

    await _storage.saveTrustedDeviceKey(deviceKey);
    await _storage.setRememberMe(true);

    if (enableBiometrics && await isBiometricAvailable()) {
      await _storage.saveBiometricPin(pin);
      await _storage.setBiometricEnabled(true);
    } else {
      await _storage.deleteBiometricPin();
      await _storage.setBiometricEnabled(false);
    }
  }

  bool get _isMobilePlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<bool> isBiometricAvailable() async {
    if (!_isMobilePlatform) return false;
    try {
      final auth = LocalAuthentication();
      return await auth.isDeviceSupported() && await auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  Future<bool> canUseBiometricUnlock() async {
    if (!await _storage.shouldUseBiometrics()) return false;
    if (!await isBiometricAvailable()) return false;
    return await _storage.getBiometricPin() != null;
  }

  Future<bool> unlockWithBiometrics() async {
    if (!await canUseBiometricUnlock()) return false;

    final auth = LocalAuthentication();
    final authenticated = await auth.authenticate(
      localizedReason: 'Authenticate to unlock your School ERP platform session.',
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
      ),
    );

    if (!authenticated) return false;

    final pin = await _storage.getBiometricPin();
    if (pin == null) {
      throw Exception('Biometric unlock is not configured. Use your MPIN.');
    }

    await unlockWithPin(pin);
    return true;
  }

  Future<void> unlockWithPin(String pin) async {
    _errorMessage = null;
    try {
      final deviceKey = await _storage.getTrustedDeviceKey();
      final refreshToken = await _storage.getRefreshToken();
      if (deviceKey == null || refreshToken == null) {
        throw Exception('Remembered session not found. Sign in again.');
      }

      final response = await _service.unlockDevice(
        deviceKey: deviceKey,
        pin: pin,
        refreshToken: refreshToken,
      );

      final accessToken = response['accessToken'];
      final newRefreshToken = response['refreshToken'];
      if (accessToken is! String || newRefreshToken is! String) {
        throw Exception('The server returned an invalid unlock response.');
      }

      await _storage.saveTokens(
        accessToken: accessToken,
        refreshToken: newRefreshToken,
        rememberMe: true,
      );
      await _loadAndVerifyProfile(accessToken);
    } catch (error) {
      _errorMessage = _cleanError(error);
      final normalizedError = _errorMessage!.toLowerCase();
      if (normalizedError.contains('remembered session is no longer valid') ||
          normalizedError.contains('remembered device not found') ||
          normalizedError.contains('invalid or expired refresh token')) {
        await _storage.clearTokens();
        _setUnauthenticated();
      }
      rethrow;
    }
  }

  Future<void> forgetRememberedDevice() async {
    final deviceKey = await _storage.getTrustedDeviceKey();
    final refreshToken = await _storage.getRefreshToken();

    try {
      if (deviceKey != null && refreshToken != null) {
        await _service.forgetDevice(
          deviceKey: deviceKey,
          refreshToken: refreshToken,
        );
      }
    } catch (error) {
      _errorMessage = _cleanError(error);
    } finally {
      await _storage.clearTokens();
      _setUnauthenticated();
    }
  }

  // --------------------------------------------------
  // VERIFY SUPER ADMIN
  // --------------------------------------------------

  Future<void> _loadAndVerifyProfile(
    String accessToken, {
    bool activate = true,
  }) async {
    final response = await _service.getProfile(accessToken);

    final profileData = response['user'] is Map<String, dynamic>
        ? response['user'] as Map<String, dynamic>
        : response;

    final user = PlatformUser.fromJson(profileData);

    if (user.id.isEmpty || user.email.isEmpty) {
      throw Exception('Invalid user profile returned by server.');
    }

    if (!user.isSuperAdmin) {
      throw Exception('Access denied. Super Admin privileges required.');
    }

    _user = user;
    _errorMessage = null;
    if (activate) {
      _status = PlatformAuthStatus.authenticated;
      notifyListeners();
    }
  }

  // --------------------------------------------------
  // LOGOUT
  // --------------------------------------------------

  Future<void> logout() async {
    final refreshToken = await _storage.getRefreshToken();

    try {
      if (refreshToken != null) {
        await _service.logoutByRefreshToken(refreshToken);
      }
    } finally {
      await _storage.clearTokens();
      _setUnauthenticated();
    }
  }

  // --------------------------------------------------
  // HELPERS
  // --------------------------------------------------

  void _setUnauthenticated() {
    _user = null;
    _status = PlatformAuthStatus.unauthenticated;

    notifyListeners();
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
