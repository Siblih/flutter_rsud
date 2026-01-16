import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/vendor_kontrak_service.dart';

class VendorKontrakPage extends StatefulWidget {
  const VendorKontrakPage({super.key});

  @override
  State<VendorKontrakPage> createState() => _VendorKontrakPageState();
}

class _VendorKontrakPageState extends State<VendorKontrakPage> {
  late Future<List<dynamic>> _futureKontrak;

  @override
  void initState() {
    super.initState();
    _futureKontrak = VendorKontrakService.fetchKontrak();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1F4A),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: _pillTitle('📄 Kontrak & Pembayaran'),
        leading: _backButton(context),
      ),

      body: FutureBuilder<List<dynamic>>(
        future: _futureKontrak,
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

          final kontraks = snapshot.data ?? [];

          if (kontraks.isEmpty) {
            return _emptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: kontraks.length,
            itemBuilder: (context, i) {
              return _kontrakCard(context, kontraks[i]);
            },
          );
        },
      ),
    );
  }

  // ================= CARD =================

  Widget _kontrakCard(BuildContext context, Map<String, dynamic> k) {
    final status = k['status'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  k['nama_pengadaan'] ?? '-',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _statusBadge(status),
            ],
          ),

          const SizedBox(height: 10),

          _infoText('Nomor Kontrak', k['nomor_kontrak'] ?? '-'),
          _infoText(
            'Nilai Kontrak',
            'Rp ${_rupiah(k['nilai_kontrak'])}',
          ),
          _infoText(
            'Tanggal',
            _formatDate(k['tanggal_kontrak']),
          ),

          const SizedBox(height: 14),

          // ACTIONS
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _primaryButton(
                label: 'Lihat Detail Kontrak',
                color: Colors.blue,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                     '/vendor-kontrak/detail',
                    arguments: k['id'],
                  );
                },
              ),
              if (status != 'selesai')
              _outlineButton(
  label: 'Upload Dokumen Pembayaran',
  color: Colors.green,
  onTap: () {
    Navigator.pushNamed(
  context,
  '/vendor-kontrak/upload',
  arguments: k['id'], // ✅ INT SAJA
);

  },
),

              _ghostButton(
                label: 'Status Pembayaran',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/vendor-kontrak/detail',
                    arguments: k['id'],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= SMALL WIDGET =================

  Widget _pillTitle(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _backButton(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(left: 12),
    child: InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: const Icon(
          Icons.arrow_back,
          color: Colors.white,
          size: 18,
        ),
      ),
    ),
  );
}


  Widget _statusBadge(String? status) {
    final isDone = status == 'selesai';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: (isDone ? Colors.green : Colors.orange).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isDone ? 'SELESAI' : 'PROSES',
        style: TextStyle(
          color: isDone ? Colors.green : Colors.orange,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: '$label: ',
          style: const TextStyle(color: Colors.blueAccent, fontSize: 12),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Text(label),
    );
  }

  Widget _outlineButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Text(label),
    );
  }

  Widget _ghostButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return TextButton(
      onPressed: onTap,
      child: const Text(
        'Status Pembayaran',
        style: TextStyle(color: Colors.blueAccent),
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Text(
        '📄 Belum ada kontrak yang tercatat',
        style: TextStyle(color: Colors.white70),
      ),
    );
  }

  // ================= UTIL =================

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '-';
    return DateFormat('dd MMM yyyy').format(DateTime.parse(date));
  }

  String _rupiah(dynamic value) {
    final num v = num.tryParse(value.toString()) ?? 0;
    return NumberFormat.currency(
      locale: 'id',
      symbol: '',
      decimalDigits: 0,
    ).format(v);
  }
}
