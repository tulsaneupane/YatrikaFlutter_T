import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://zebralike-inquirable-almeda.ngrok-free.dev',
  );

  static final http.Client _http = http.Client();
  static String? _authToken;
  static const String _tokenKey = 'auth_token';
  static String? getToken() => _authToken;
  /// 1. Initialize the client (Call this in main.dart)
  /// Loads the stored token from local storage into memory.
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(_tokenKey);
  }

  /// 2. Set and Persist the Auth Token
  /// Use this during Login/Registration success.
  static Future<void> setAuthToken(String? token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString(_tokenKey, token);
    } else {
      await prefs.remove(_tokenKey);
    }
  }

  /// 3. Clear the Auth Token (Logout)
  static Future<void> logout() async {
    await setAuthToken(null);
  }

  static Map<String, String> _defaultHeaders() {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  static Map<String, String> headers() => _defaultHeaders();

  static Uri _uri(String path, [Map<String, dynamic>? query]) {
    final uri = Uri.parse(baseUrl + path);
    if (query != null) {
      return uri.replace(
        queryParameters: query.map((k, v) => MapEntry(k, '$v')),
      );
    }
    return uri;
  }

  // --- HTTP METHODS ---

  static Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    final uri = _uri(path, query);
    final res = await _http
        .get(uri, headers: _defaultHeaders())
        .timeout(const Duration(seconds: 20));
    return _decodeOrThrow(res);
  }

  static Future<dynamic> post(String path, {Object? body, Map<String, String>? headers}) async {
    final uri = _uri(path);
    final merged = {..._defaultHeaders(), if (headers != null) ...headers};
    final res = await _http
        .post(
          uri,
          headers: merged,
          body: body is String ? body : jsonEncode(body),
        )
        .timeout(const Duration(seconds: 20));
    return _decodeOrThrow(res);
  }

  static Future<dynamic> put(String path, {Object? body, Map<String, String>? headers}) async {
    final uri = _uri(path);
    final merged = {..._defaultHeaders(), if (headers != null) ...headers};
    final res = await _http
        .put(
          uri,
          headers: merged,
          body: body is String ? body : jsonEncode(body),
        )
        .timeout(const Duration(seconds: 20));
    return _decodeOrThrow(res);
  }

  static Future<dynamic> patch(String path, {Object? body, Map<String, String>? headers}) async {
    final uri = _uri(path);
    final merged = {..._defaultHeaders(), if (headers != null) ...headers};
    final res = await _http
        .patch(
          uri,
          headers: merged,
          body: body is String ? body : jsonEncode(body),
        )
        .timeout(const Duration(seconds: 20));
    return _decodeOrThrow(res);
  }

  static Future<dynamic> delete(String path, {Map<String, dynamic>? query}) async {
    final uri = _uri(path, query);
    final res = await _http
        .delete(uri, headers: _defaultHeaders())
        .timeout(const Duration(seconds: 20));
    return _decodeOrThrow(res);
  }

  static dynamic _decodeOrThrow(http.Response res) {
    final code = res.statusCode;

    // Handle session expiry (Unauthorized)
    if (code == 401) {
      logout(); // Automatically clear token on the client side
      throw ApiException("Session expired. Please log in again.", statusCode: 401);
    }

    if (code >= 200 && code < 300) {
      return res.body.isEmpty ? null : jsonDecode(res.body);
    } else {
      String message = "An error occurred";
      try {
        final errorBody = jsonDecode(res.body);
        // Extracts detailed error from your Spring Boot Backend
        message = errorBody['message'] ?? errorBody['error'] ?? message;
      } catch (_) {}
      throw ApiException(message, statusCode: code);
    }
  }


  /// Helper to convert a relative image path into a full URL
  static String getFullImageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) return "";
    
    // If it's already a full URL (starts with http), return it as is
    if (relativePath.startsWith('http')) return relativePath;
    
    // Clean up slashes and combine with baseUrl
    final path = relativePath.startsWith('/') ? relativePath : '/$relativePath';
    return "$baseUrl$path";
  }
}