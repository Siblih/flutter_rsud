import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import '../services/auth_service.dart';

class VendorService {
  /// =========================
  /// FETCH PROFILE VENDOR
  /// =========================
  static Future<Map<String, dynamic>> fetchProfile() async {
    final token = await AuthService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan, silakan login ulang');
    }

    print('🔥 TOKEN DI VENDOR SERVICE: $token');

    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/profile'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) {
      print('❌ RESPONSE BODY: ${res.body}');
      throw Exception('Gagal mengambil profil vendor (${res.statusCode})');
    }

    final body = jsonDecode(res.body);

    // 🔥 Jika API membungkus data
    if (body is Map && body.containsKey('data')) {
      return Map<String, dynamic>.from(body['data']);
    }

    // 🔥 Jika langsung object (punyamu)
    return Map<String, dynamic>.from(body);
  }
}
