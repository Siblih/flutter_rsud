import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/pengadaan_service.dart';

class VendorPengadaanDetailPage extends StatefulWidget {
  const VendorPengadaanDetailPage({super.key});

  @override
  State<VendorPengadaanDetailPage> createState() =>
      _VendorPengadaanDetailPageState();
}

class _VendorPengadaanDetailPageState
    extends State<VendorPengadaanDetailPage> {
  Map<String, dynamic>? data;
  bool loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = ModalRoute.of(context)!.settings.arguments as int;
    _load(id);
  }

  Future<void> _load(int id) async {
    final res = await PengadaanService.fetchDetail(id);
    setState(() {
      data = res;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pengadaan = data!;
    final penawaran = pengadaan['penawaran'];

    return Scaffold(
      backgroundColor: const Color(0xFF1A1F4A),
     appBar: AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  centerTitle: true,

  // ⬅️ BACK BUTTON ESTETIK
  leading: Padding(
    padding: const EdgeInsets.only(left: 12),
    child: InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(30),
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

  // 🏷️ TITLE PILL
  title: Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.35),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: Colors.white24),
    ),
    child: const Text(
      '📋 Detail Pengadaan',
      style: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),


      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          children: [
            _infoPengadaan(pengadaan),
            const SizedBox(height: 16),
            _detailPekerjaan(pengadaan),
            const SizedBox(height: 16),
            penawaran == null
                ? _formPenawaran(pengadaan['id'])
                : _statusPenawaran(penawaran),
          ],
        ),
      ),
    );
  }

  /* =======================
   | FORMATTER (SATU SAJA)
   ======================= */

  String _formatDate(dynamic value) {
    if (value == null || value.toString().isEmpty) return '-';

    try {
      final date = DateTime.parse(value.toString());
      return DateFormat('dd MMM yyyy HH:mm').format(date);
    } catch (_) {
      return '-';
    }
  }

  String _formatRupiah(dynamic v) {
    final num value =
        v is num ? v : num.tryParse(v.toString()) ?? 0;
    return NumberFormat.currency(
      locale: 'id',
      symbol: '',
      decimalDigits: 0,
    ).format(value);
  }

  /* =======================
   | INFO PENGADAAN
   ======================= */

  Widget _infoPengadaan(Map<String, dynamic> p) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p['nama_pengadaan'] ?? '-',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Kode: ${p['kode_tender'] ?? '-'}',
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              _statusBadge(p['status'] ?? 'unknown'),
            ],
          ),
          const SizedBox(height: 10),
          _infoRow('🏢 Unit', p['unit'] ?? '-'),
          _infoRow(
            '📅 Batas Penawaran',
            _formatDate(p['batas_penawaran']),
          ),
          _infoRow(
            '💰 Anggaran',
            'Rp ${_formatRupiah(p['estimasi_anggaran'])}',
          ),
        ],
      ),
    );
  }

  /* =======================
   | DETAIL PEKERJAAN
   ======================= */

  Widget _detailPekerjaan(Map<String, dynamic> p) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
  children: const [
    Icon(Icons.assignment, color: Colors.blueAccent, size: 16),
    SizedBox(width: 6),
    Text(
      'Detail Pekerjaan',
      style: TextStyle(
        color: Colors.blueAccent,
        fontSize: 13,
        fontWeight: FontWeight.bold,
      ),
    ),
  ],
),
const SizedBox(height: 12),

          const SizedBox(height: 10),
          _detailItem(
            'Uraian Pekerjaan',
            p['uraian_pekerjaan'] ?? '-',
          ),
          _detailItem(
            'Lokasi Pekerjaan',
            p['lokasi_pekerjaan'] ?? '-',
          ),
          _detailItem(
            'Waktu Pelaksanaan',
            _formatDate(p['waktu_pelaksanaan']),
          ),
        ],
      ),
    );
  }

  Widget _detailItem(String title, String value) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.25), // 🔥 PEMBUNGKUS
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white24),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.blueAccent,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value.isNotEmpty ? value : '-',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            height: 1.5, // 🔥 SPASI BARIS
          ),
        ),
      ],
    ),
  );
}


  /* =======================
   | FORM PENAWARAN
   ======================= */

  Widget _formPenawaran(int id) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📤 Kirim Penawaran',
            style: TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          const TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Harga Penawaran',
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // TODO: submit penawaran
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('🚀 Kirim Penawaran'),
          ),
        ],
      ),
    );
  }

  /* =======================
   | STATUS PENAWARAN
   ======================= */

  Widget _statusPenawaran(Map<String, dynamic> p) {
  return _card(
    child: Column(
      children: [
        const Icon(Icons.check_circle, color: Colors.greenAccent, size: 28),
        const SizedBox(height: 8),
        const Text(
          'Penawaran Terkirim',
          style: TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Rp ${_formatRupiah(p['harga'])}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _statusBadge(p['status'] ?? '-'),
      ],
    ),
  );
}


  /* =======================
   | UI UTIL
   ======================= */

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white24),
      ),
      child: child,
    );
  }

  Widget _infoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}


  Widget _statusBadge(String status) {
    Color color = Colors.orange;
    if (status == 'selesai' || status == 'menang') color = Colors.green;
    if (status == 'ditolak') color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 11),
      ),
    );
  }
}
