import '../services/api_client.dart';

class AuthService {

  static Future<String?> getToken() async {
    // Simply return the token currently held by the ApiClient
    return ApiClient.getToken();
  }

  static Future<void> logout() async {
    await ApiClient.logout();
  }

  static Future<Map<String, dynamic>> me() async {
    final data = await ApiClient.get('/api/auth/me');
    return data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updateMe(
    Map<String, dynamic> body,
  ) async {
    final data = await ApiClient.put('/api/auth/me', body: body);
    return data as Map<String, dynamic>;
  }

  static Future<void> deleteMe() async {
    await ApiClient.delete('/api/auth/me');
  }

  static Future<Map<String, dynamic>> register(
    Map<String, dynamic> body,
  ) async {
    final data = await ApiClient.post('/api/auth/register', body: body);
    return data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> login(Map<String, dynamic> body) async {
    final data = await ApiClient.post('/api/auth/login', body: body);
    // Optionally set token if present in response
    if (data is Map && data['token'] != null) {
      ApiClient.setAuthToken(data['token'].toString());
    }
    return data as Map<String, dynamic>;
  }
}
