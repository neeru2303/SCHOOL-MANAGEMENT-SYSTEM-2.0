import 'dart:convert';

import 'package:http/http.dart' as http;

class PlatformAuthService {
  PlatformAuthService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api/v1',
  );

  Uri _uri(String path) {
    return Uri.parse('$baseUrl$path');
  }

  Map<String, dynamic> _decode(http.Response response) {
    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw Exception('Unexpected response from the server.');
  }

  Map<String, dynamic> _unwrap(Map<String, dynamic> response) {
    final data = response['data'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    return response;
  }

  String _errorMessage(http.Response response) {
    try {
      final body = _decode(response);
      final message = body['message'];

      if (message is List) {
        return message.join('\n');
      }

      if (message is String) {
        return message;
      }
    } catch (_) {
      // Use the generic message below.
    }

    return 'Request failed (${response.statusCode}).';
  }

  // --------------------------------------------------
  // LOGIN
  // --------------------------------------------------

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      _uri('/platform/auth/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_errorMessage(response));
    }

    return _unwrap(_decode(response));
  }

  // --------------------------------------------------
  // GET PROFILE
  // --------------------------------------------------

  Future<Map<String, dynamic>> getProfile(String accessToken) async {
    final response = await _client.get(
      _uri('/platform/auth/me'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(_errorMessage(response));
    }

    return _unwrap(_decode(response));
  }

  // --------------------------------------------------
  // REFRESH TOKEN
  // --------------------------------------------------

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await _client.post(
      _uri('/platform/auth/refresh'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_errorMessage(response));
    }

    return _unwrap(_decode(response));
  }

  Future<Map<String, dynamic>> rememberDevice({
    required String accessToken,
    required String deviceKey,
    required String pin,
  }) async {
    final response = await _client.post(
      _uri('/platform/auth/device/remember'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
      body: jsonEncode({'deviceKey': deviceKey, 'pin': pin}),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_errorMessage(response));
    }
    return _unwrap(_decode(response));
  }

  Future<Map<String, dynamic>> unlockDevice({
    required String deviceKey,
    required String pin,
    required String refreshToken,
  }) async {
    final response = await _client.post(
      _uri('/platform/auth/device/unlock'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'deviceKey': deviceKey,
        'pin': pin,
        'refreshToken': refreshToken,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_errorMessage(response));
    }
    return _unwrap(_decode(response));
  }

  Future<void> forgetDevice({
    required String deviceKey,
    required String refreshToken,
  }) async {
    final response = await _client.post(
      _uri('/platform/auth/device/forget'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'deviceKey': deviceKey,
        'refreshToken': refreshToken,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_errorMessage(response));
    }
  }

  // --------------------------------------------------
  // LOGOUT
  // --------------------------------------------------

  Future<void> logout(String accessToken) async {
    final response = await _client.post(
      _uri('/platform/auth/logout'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201 &&
        response.statusCode != 204) {
      throw Exception(_errorMessage(response));
    }
  }

  void dispose() {
    _client.close();
  }
}
