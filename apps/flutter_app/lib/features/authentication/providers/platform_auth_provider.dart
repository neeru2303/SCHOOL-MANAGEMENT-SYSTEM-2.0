import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

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

  Future<void> rememberCurrentDevice(String pin) async {
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
      if (_errorMessage!.contains('remembered session is no longer valid')) {
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
    final accessToken = await _storage.getAccessToken();

    try {
      if (accessToken != null) {
        await _service.logout(accessToken);
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
