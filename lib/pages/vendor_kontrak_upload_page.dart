import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import '../../services/auth_service.dart';



class VendorKontrakUploadPage extends StatefulWidget {
  final int kontrakId;

  const VendorKontrakUploadPage({
    super.key,
    required this.kontrakId,
  });

  @override
  State<VendorKontrakUploadPage> createState() =>
      _VendorKontrakUploadPageState();
}

class _VendorKontrakUploadPageState extends State<VendorKontrakUploadPage> {
  final Map<String, File?> _pickedFiles = {};

  Map<String, dynamic>? kontrak;
  bool loading = true;

  final Map<String, String> fields = {
    'po_signed': 'PO (Ditandatangani)',
    'bast_signed': 'BAST (Ditandatangani)',
    'invoice': 'Invoice',
    'faktur_pajak': 'Faktur Pajak',
    'surat_permohonan': 'Surat Permohonan Pembayaran',
  };

  @override
  void initState() {
    super.initState();
    fetchKontrakDetail();
  }

  // ================= FETCH KONTRAK =================
  Future<void> fetchKontrakDetail() async {
  try {
    final token = await AuthService.getToken();

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/vendor/kontrak/${widget.kontrakId}',
    );

    debugPrint('FETCH DETAIL => $uri');

    final res = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }

    final json = jsonDecode(res.body);

    if (json['success'] == true) {
      setState(() {
        kontrak = json['data'];
        loading = false;
      });
    } else {
      throw Exception('Gagal memuat kontrak');
    }
  } catch (e) {
    debugPrint('ERROR FETCH DETAIL: $e');
    setState(() => loading = false);
  }
}


  // ================= PICK FILE =================
  Future<void> _pickFile(String key) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _pickedFiles[key] = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A1F4A),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (kontrak == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A1F4A),
        body: Center(
          child: Text('Data kontrak tidak ditemukan',
              style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
     backgroundColor: const Color(0xFF1A1F4A),
appBar: AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  centerTitle: true,

  title: Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.35),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: Colors.white24),
    ),
    child: const Text(
      'Upload Dokumen Pembayaran',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 15,
        letterSpacing: 0.4,
      ),
    ),
  ),

  leading: Padding(
    padding: const EdgeInsets.only(left: 10),
    child: InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new,
          size: 18,
          color: Colors.white,
        ),
      ),
    ),
  ),
),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ================= INFO KONTRAK =================
            _glassCard(
              children: [
                _infoRow(
                  'Nomor Kontrak',
                  kontrak!['nomor_kontrak'] ?? '-',
                ),
                _infoRow(
                  'Pengadaan',
                  kontrak!['pengadaan']?['nama_pengadaan'] ?? '-',
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// ================= DOKUMEN =================
            _glassCard(
              title: '📎 Dokumen Pembayaran',
              children: fields.entries.map((e) {
                return _docItem(
                  label: e.value,
                  field: e.key,
                  existingFile: kontrak!['dokumen']?[e.key],
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            /// ================= SUBMIT =================
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                debugPrint('Kontrak ID: ${widget.kontrakId}');
                debugPrint('Files ready: $_pickedFiles');
                // TODO: multipart upload ke Laravel
              },
              child: const Text(
                'Upload Dokumen',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI =================

  Widget _docItem({
    required String label,
    required String field,
    dynamic existingFile,
  }) {
    final pickedFile = _pickedFiles[field];

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.blueAccent)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (existingFile != null && pickedFile == null)
                        const Text('✔ Sudah diunggah',
                            style: TextStyle(color: Colors.greenAccent, fontSize: 12))
                      else if (pickedFile != null)
                        const Text('🆕 File baru dipilih',
                            style: TextStyle(color: Colors.orangeAccent, fontSize: 12))
                      else
                        const Text('❌ Belum diunggah',
                            style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        pickedFile != null
                            ? pickedFile.path.split('/').last
                            : existingFile?.split('/').last ?? '-',
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _pickFile(field),
                  child: Text(
                    existingFile != null || pickedFile != null ? 'Ganti' : 'Upload',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassCard({String? title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title,
                style: const TextStyle(
                    color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
          ],
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.blueAccent)),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _pillTitle(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      );

  Widget _backButton(BuildContext context) =>
      IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      );
}
