import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import 'auth_service.dart';

class VendorDocumentService {
  static Future<Map<String, dynamic>?> fetchDocuments() async {
    final token = await AuthService.getToken();

    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/vendor/documents'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    // 🔥 DEBUG WAJIB (PAKAI print, BUKAN debugPrint)
    print('=== FETCH VENDOR DOCUMENTS ===');
    print('URL    : ${ApiConfig.baseUrl}/vendor/documents');
    print('TOKEN  : $token');
    print('STATUS : ${res.statusCode}');
    print('BODY   : ${res.body}');
    print('==============================');

    if (res.statusCode != 200) {
      throw Exception('Gagal mengambil dokumen');
    }

    final body = jsonDecode(res.body);
    return body['data'];
  }
}
