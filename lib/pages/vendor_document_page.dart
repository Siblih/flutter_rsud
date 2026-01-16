import 'package:flutter/material.dart';
import '../services/vendor_document_service.dart';
import 'package:url_launcher/url_launcher.dart';


class VendorDocumentPage extends StatefulWidget {
  const VendorDocumentPage({super.key});

  @override
  State<VendorDocumentPage> createState() => _VendorDocumentPageState();
}

class _VendorDocumentPageState extends State<VendorDocumentPage> {
  Map<String, dynamic>? documents;
  bool loading = true;

  final fields = const {
    'nib': '🧾 NIB (Nomor Induk Berusaha)',
    'pengalaman': '🧾 KBLI (Surat Klasifikasi)',
    'siup': '📑 PB UMKU (Surat Izin Usaha)',
    'npwp': '💳 NPWP',
    'akta_perusahaan': '📘 Akta Pendirian',
    'domisili': '🏠 Surat Domisili',
    'sertifikat_halal': '🕌 Sertifikat Halal',
    'sertifikat_iso': '🏅 Sertifikat ISO',
  };

  @override
  void initState() {
    super.initState();
    load();
  }

Future<void> _openDocument(String url) async {
  final uri = Uri.parse(url);

  if (!await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  )) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gagal membuka dokumen')),
    );
  }
}

  Future<void> load() async {
    documents = await VendorDocumentService.fetchDocuments();
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1F4A),
     appBar: AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  centerTitle: true,

  // 🔙 BACK BUTTON ESTETIK
  leading: GestureDetector(
    onTap: () => Navigator.pop(context),
    child: Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: const Icon(
        Icons.arrow_back_ios_new_rounded,
        color: Colors.white,
        size: 18,
      ),
    ),
  ),

  // 🧾 TITLE ESTETIK
  title: const Text(
    'Dokumen Vendor',
    style: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 18,
      letterSpacing: 0.4,
      color: Colors.white,
    ),
  ),
),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: documents == null
                  ? _emptyState()
                  : _documentTable(),
            ),
    );
  }

  Widget _emptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.yellow.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            '⚠️ Anda belum mengunggah dokumen apapun.',
            style: TextStyle(color: Colors.yellowAccent),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            // ke halaman upload
          },
          child: const Text('Upload Sekarang'),
        )
      ],
    );
  }

  Widget _documentTable() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: fields.entries.map((e) {
          final path = documents![e.key];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    e.value,
                    style: const TextStyle(color: Colors.blueAccent),
                  ),
                ),
                path != null && path.toString().isNotEmpty
    ? ElevatedButton.icon(
        onPressed: () => _openDocument(path),
        icon: const Icon(Icons.visibility, size: 18),
        label: const Text('Lihat'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        ),
      )

                    : const Text(
                        'Belum diupload',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
