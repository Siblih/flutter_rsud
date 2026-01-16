import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../config/api.dart';
import 'auth_service.dart';

class ProductService {
  // ================= LIST =================
  static Future<List<dynamic>> fetchProducts() async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/vendor/products"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data'];
    }
    throw Exception("Gagal mengambil produk");
  }

  // ================= DETAIL =================
  static Future<Map<String, dynamic>> fetchProductDetail(int id) async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/vendor/products/$id"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Map<String, dynamic>.from(json['data']);
    }

    throw Exception("API ERROR ${response.statusCode}");
  }

  // ================= CREATE (JSON / MULTIPART) =================
  static Future<void> createProduct(
    Map<String, dynamic> data, [
    List<XFile>? photos,
  ]) async {
    final token = await AuthService.getToken();

    // 🔥 kalau tidak ada foto → JSON biasa
    if (photos == null || photos.isEmpty) {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/vendor/products"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(data),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Gagal menambah produk");
      }
      return;
    }

    // 🔥 MULTIPART (ADA FOTO)
    final request = http.MultipartRequest(
      'POST',
      Uri.parse("${ApiConfig.baseUrl}/vendor/products"),
    );

    request.headers.addAll({
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });

    data.forEach((k, v) {
      if (v != null) request.fields[k] = v.toString();
    });

    for (var photo in photos) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'images[]',
          photo.path,
        ),
      );
    }

    final res = await request.send();
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception(await res.stream.bytesToString());
    }
  }

  // ================= UPDATE (JSON / MULTIPART) =================
  static Future<void> updateProduct(
    int id,
    Map<String, dynamic> data, [
    List<XFile>? photos,
  ]) async {
    final token = await AuthService.getToken();

    // 🔥 TANPA FOTO → PUT JSON
    if (photos == null || photos.isEmpty) {
      final response = await http.put(
        Uri.parse("${ApiConfig.baseUrl}/vendor/products/$id"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(data),
      );

      if (response.statusCode != 200) {
        throw Exception("Gagal update produk");
      }
      return;
    }

    // 🔥 MULTIPART + METHOD SPOOFING
    final request = http.MultipartRequest(
      'POST',
      Uri.parse("${ApiConfig.baseUrl}/vendor/products/$id"),
    );

    request.fields['_method'] = 'PUT';

    request.headers.addAll({
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });

    data.forEach((k, v) {
      if (v != null) request.fields[k] = v.toString();
    });

    for (var photo in photos) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'images[]',
          photo.path,
        ),
      );
    }

    final res = await request.send();
    if (res.statusCode != 200) {
      throw Exception(await res.stream.bytesToString());
    }
  }

  // ================= DELETE =================
  static Future<void> deleteProduct(int id) async {
    final token = await AuthService.getToken();

    final response = await http.delete(
      Uri.parse("${ApiConfig.baseUrl}/vendor/products/$id"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Gagal hapus produk");
    }
  }
}
