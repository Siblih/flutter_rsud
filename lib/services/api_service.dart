import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import 'auth_service.dart';

class ApiService {
  static Future<String> testApi() async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/test"),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['message'];
    } else {
      throw Exception('Unauthorized');
    }
  }
}
