import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import 'auth_service.dart';

class AccountService {
  static Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final token = await AuthService.getToken();

    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/vendor/account/password'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'current_password': oldPassword,
        'new_password': newPassword,
        'new_password_confirmation': confirmPassword,
      }),
    );

    final body = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw Exception(body['message'] ?? 'Gagal ubah password');
    }
  }

  static Future<void> logout() async {
    final token = await AuthService.getToken();
    await http.post(
      Uri.parse('${ApiConfig.baseUrl}/logout'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    await AuthService.clearToken();
  }
}
