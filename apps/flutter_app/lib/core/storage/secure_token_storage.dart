import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureTokenStorage {
  SecureTokenStorage._();

  static final SecureTokenStorage instance = SecureTokenStorage._();

  static const _storage = FlutterSecureStorage();

  static const _accessTokenKey = 'platform_access_token';
  static const _refreshTokenKey = 'platform_refresh_token';
  static const _rememberMeKey = 'platform_remember_me';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required bool rememberMe,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);

    await _storage.write(key: _refreshTokenKey, value: refreshToken);

    final preferences = await SharedPreferences.getInstance();

    await preferences.setBool(_rememberMeKey, rememberMe);
  }

  Future<String?> getAccessToken() {
    return _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() {
    return _storage.read(key: _refreshTokenKey);
  }

  Future<bool> shouldRememberMe() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getBool(_rememberMeKey) ?? false;
  }

  Future<void> updateAccessToken(String token) {
    return _storage.write(key: _accessTokenKey, value: token);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);

    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_rememberMeKey);
  }
}
