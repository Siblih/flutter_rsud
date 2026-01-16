import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api.dart';
import 'auth_service.dart';

class PengadaanService {
  /// =========================
  /// FETCH PENGADAAN AKTIF (VENDOR)
  /// =========================
  static Future<List<dynamic>> fetchAktif() async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/vendor/pengadaan'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil pengadaan');
    }

    final body = jsonDecode(response.body);

    // 🔹 Jika API membungkus data
    if (body is Map && body.containsKey('data')) {
      return List<dynamic>.from(body['data']);
    }

    // 🔹 Jika API langsung array
    if (body is List) {
      return body;
    }

    throw Exception('Format response pengadaan tidak dikenali');
  }

  /// =========================
  /// ALIAS (BIAR KODE LAMA AMAN)
  /// =========================
  static Future<List<dynamic>> getPengadaans() async {
    return fetchAktif();
  }

  /// =========================
  /// FETCH DETAIL PENGADAAN
  /// =========================
  static Future<Map<String, dynamic>> fetchDetail(int id) async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/vendor/pengadaan/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      print(response.body); // 🔥 DEBUG kalau error lagi
      throw Exception('Gagal mengambil detail pengadaan');
    }

    final body = jsonDecode(response.body);

    if (body is Map && body.containsKey('data')) {
      return Map<String, dynamic>.from(body['data']);
    }

    throw Exception('Format response detail pengadaan tidak dikenali');
  }
}
