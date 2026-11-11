import 'package:flutter/material.dart';

import '../../../core/storage/secure_token_storage.dart';
import '../models/platform_user.dart';
import '../services/platform_auth_service.dart';

enum PlatformAuthStatus { initializing, authenticated, unauthenticated }

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

      var accessToken = await _storage.getAccessToken();

      if (accessToken == null) {
        _setUnauthenticated();
        return;
      }

      try {
        await _loadAndVerifyProfile(accessToken);
      } catch (_) {
        final refreshToken = await _storage.getRefreshToken();

        if (refreshToken == null) {
          throw Exception('Session expired.');
        }

        final response = await _service.refreshToken(refreshToken);

        final newAccessToken = response['accessToken'];
        final newRefreshToken = response['refreshToken'];

        if (newAccessToken is! String || newRefreshToken is! String) {
          throw Exception('Invalid refresh response.');
        }

        await _storage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
          rememberMe: true,
        );

        accessToken = newAccessToken;

        await _loadAndVerifyProfile(accessToken);
      }
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
    required bool rememberMe,
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
        rememberMe: rememberMe,
      );

      await _loadAndVerifyProfile(accessToken);
    } catch (error) {
      await _storage.clearTokens();

      _errorMessage = _cleanError(error);

      _setUnauthenticated();

      rethrow;
    }
  }

  // --------------------------------------------------
  // VERIFY SUPER ADMIN
  // --------------------------------------------------

  Future<void> _loadAndVerifyProfile(String accessToken) async {
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
    _status = PlatformAuthStatus.authenticated;

    notifyListeners();
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
