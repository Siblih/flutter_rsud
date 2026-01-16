import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/vendor_kontrak_service.dart';

class VendorKontrakDetailPage extends StatefulWidget {
  const VendorKontrakDetailPage({super.key});

  @override
  State<VendorKontrakDetailPage> createState() =>
      _VendorKontrakDetailPageState();
}

class _VendorKontrakDetailPageState extends State<VendorKontrakDetailPage> {
  late Future<Map<String, dynamic>> _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final int id = ModalRoute.of(context)!.settings.arguments as int;
    _future = VendorKontrakService.fetchDetail(id);
  }

  @override
  Widget build(BuildContext context) {
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
      '📄 Detail Kontrak',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 16,
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


      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final k = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// ================= KARTU KONTRAK =================
                _glassCard(
                  children: [
                    _row('Nomor Kontrak', k['nomor_kontrak']),
                    _row('Tanggal Kontrak', _formatDate(k['tanggal_kontrak'])),
                    _row(
                      'Nilai Kontrak',
                      'Rp ${_rupiah(k['nilai_kontrak'])}',
                    ),
                    _statusRow(k['status']),
                  ],
                ),

                const SizedBox(height: 20),

                /// ================= INFO PENGADAAN =================
                if (k['pengadaan'] != null)
                  _glassCard(
                    title: '📦 Informasi Pengadaan',
                    children: [
                      Text(
                        k['pengadaan']['nama_pengadaan'] ?? '-',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        k['pengadaan']['uraian_pekerjaan'] ?? '-',
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 20),

                /// ================= DOKUMEN =================
                _glassCard(
                  title: '📎 Dokumen Pembayaran',
                  children: [
                    _docRow('PO (Ditandatangani)', k['po_signed']),
                    _docRow('BAST', k['bast_signed']),
                    _docRow('Invoice', k['invoice']),
                    _docRow('Faktur Pajak', k['faktur_pajak']),
                    _docRow('Surat Permohonan', k['surat_permohonan']),
                  ],
                ),

                const SizedBox(height: 20),

                /// ================= STATUS PEMBAYARAN =================
                _glassCard(
                  title: '💳 Status Pembayaran',
                  children: [
                    _paymentStatus(k['status_pembayaran']),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// ================= UI PART =================

  Widget _glassCard({String? title, required List<Widget> children}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 18),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.10),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title,
            style: const TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(color: Colors.white24),
          const SizedBox(height: 14),
        ],
        ...children,
      ],
    ),
  );
}


  Widget _row(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.blueAccent,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}


  Widget _statusRow(String? status) {
  Color color = Colors.orange;
  String text = 'AKTIF';

  if (status == 'selesai') {
    color = Colors.green;
    text = 'SELESAI';
  } else if (status == 'dibatalkan') {
    color = Colors.red;
    text = 'DIBATALKAN';
  }

  return Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Status',
          style: TextStyle(color: Colors.blueAccent, fontSize: 12),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.18),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    ),
  );
}


  Widget _docRow(String label, String? file) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.blueAccent,
              fontSize: 12,
            ),
          ),
        ),
        file != null
            ? InkWell(
                onTap: () {
                  // TODO: buka dokumen
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.visibility,
                          size: 14, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'Lihat',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : const Text(
                'Belum ada',
                style: TextStyle(
                  color: Colors.white54,
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                ),
              ),
      ],
    ),
  );
}

  Widget _paymentStatus(String? status) {
  if (status == 'paid') {
    return _badge('✅ Sudah Dibayar', Colors.green);
  } else if (status == 'process') {
    return _badge('⏳ Dalam Proses Pembayaran', Colors.orange);
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _badge('❌ Belum Dibayar', Colors.red),
      const SizedBox(height: 8),
      const Text(
        'Pembayaran diproses setelah seluruh dokumen diverifikasi.',
        style: TextStyle(
          color: Colors.blueAccent,
          fontSize: 12,
        ),
      ),
    ],
  );
}


  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// ================= UTIL =================

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '-';
    return DateFormat('dd MMM yyyy').format(DateTime.parse(date));
  }

  String _rupiah(dynamic v) {
    final num n = num.tryParse(v.toString()) ?? 0;
    return NumberFormat.currency(
      locale: 'id',
      symbol: '',
      decimalDigits: 0,
    ).format(n);
  }
}
