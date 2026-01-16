import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import 'auth_service.dart';

class VendorKontrakService {
  /// =========================
  /// LIST KONTRAK VENDOR
  /// =========================
  static Future<List<dynamic>> fetchKontrak() async {
    final token = await AuthService.getToken();

    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/vendor/kontrak'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Gagal mengambil data kontrak');
    }

    final body = jsonDecode(res.body);
    return List<dynamic>.from(body['data']);
  }

  /// =========================
  /// DETAIL KONTRAK
  /// =========================
  static Future<Map<String, dynamic>> fetchDetail(int id) async {
    final token = await AuthService.getToken();

    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/vendor/kontrak/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Gagal mengambil detail kontrak');
    }

    final body = jsonDecode(res.body);
    return Map<String, dynamic>.from(body['data']);
  }

  /// =========================
  /// UPLOAD DOKUMEN (MULTIPART)
  /// =========================
  static Future<void> uploadDokumen({
    required int kontrakId,
    required Map<String, File?> files,
  }) async {
    final token = await AuthService.getToken();

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/vendor/kontrak/$kontrakId/upload',
    );

    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    files.forEach((key, file) {
      if (file != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            key,
            file.readAsBytesSync(),
            filename: file.path.split('/').last,
          ),
        );
      }
    });

    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Gagal upload dokumen');
    }
  }
}
