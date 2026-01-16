import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../layouts/vendor_layout.dart';
import '../services/pengadaan_service.dart';

class VendorPengadaanPage extends StatefulWidget {
  const VendorPengadaanPage({super.key});

  @override
  State<VendorPengadaanPage> createState() => _VendorPengadaanPageState();
}

class _VendorPengadaanPageState extends State<VendorPengadaanPage> {
  List<dynamic> pengadaans = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadPengadaan();
  }

  Future<void> _loadPengadaan() async {
    try {
      final data = await PengadaanService.fetchAktif();
      setState(() {
        pengadaans = data;
        loading = false;
      });
    } catch (_) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return VendorLayout(
      currentIndex: 1,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1F4A), Color(0xFF2B3370)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : pengadaans.isEmpty
                ? _emptyState()
                : ListView(
                    children: [
                      _header(),
                      const SizedBox(height: 16),
                      ...pengadaans.map(_pengadaanCard),
                    ],
                  ),
      ),
    );
  }

  // ================= HEADER =================

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '📦 Daftar Tender & Kompetisi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _loadPengadaan,
        ),
      ],
    );
  }

  // ================= CARD =================

  Widget _pengadaanCard(dynamic item) {
    final penawaran = item['penawaran'];
    final status = item['status'];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['nama_paket'],
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kode: ${item['kode_tender']}',
                      style:
                          const TextStyle(color: Colors.blueAccent, fontSize: 11),
                    ),
                  ],
                ),
              ),
              _statusBadge(status),
            ],
          ),

          const SizedBox(height: 10),

          // INFO
          Text(
            '📅 Batas Penawaran: ${_formatDate(item['batas_penawaran'])}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Text(
            '💰 Estimasi Anggaran: Rp ${_formatRupiah(item['estimasi_anggaran'])}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),

          const SizedBox(height: 14),

          // FOOTER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              penawaran != null
                  ? _penawaranBadge(penawaran['status'])
                  : const Text(
                      'Belum mengirim penawaran',
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          fontStyle: FontStyle.italic),
                    ),
              ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(
          context,
          '/vendor-pengadaan/detail',
          arguments: item['id'], // ⬅️ WAJIB
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        penawaran != null ? 'Lihat Detail' : 'Kirim Penawaran',
        style: const TextStyle(fontSize: 11),
      ),

              )
            ],
          )
        ],
      ),
    );
  }

  // ================= BADGE =================

  Widget _statusBadge(String status) {
    Color color = Colors.grey;
    if (status == 'berjalan') color = Colors.orange;
    if (status == 'selesai') color = Colors.green;

    return _badge(status.toUpperCase(), color);
  }

  Widget _penawaranBadge(String status) {
    Color color = Colors.orange;
    if (status == 'menang') color = Colors.green;
    if (status == 'ditolak') color = Colors.red;

    return _badge('Status: ${status.toUpperCase()}', color);
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11),
      ),
    );
  }

  // ================= EMPTY =================

  Widget _emptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Text(
          '📭 Belum ada tender atau kompetisi',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }

  // ================= UTILS =================

  String _formatDate(String date) {
    return DateFormat('dd MMM yyyy HH:mm')
        .format(DateTime.parse(date));
  }

  String _formatRupiah(dynamic value) {
  if (value == null) return '0';

  final numValue = value is num
      ? value
      : num.tryParse(value.toString()) ?? 0;

  return NumberFormat.currency(
    locale: 'id',
    symbol: '',
    decimalDigits: 0,
  ).format(numValue);
}

}
