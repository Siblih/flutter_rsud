import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../config/api.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;
  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  Map<String, dynamic>? product;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
  try {
    final data = await ProductService.fetchProductDetail(widget.productId);
    print('DETAIL PRODUCT = $data');

    setState(() {
      product = data;
      loading = false;
    });
  } catch (e) {
    print('ERROR DETAIL = $e');
    setState(() => loading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (product == null) {
      return Scaffold(
        body: Center(child: Text("Produk tidak ditemukan")),
      );
    }

    final p = product!;
    return Scaffold(
      backgroundColor: const Color(0xFF1A1F4A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F4A),
        title: const Text('Detail Produk'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white24),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// FOTO + INFO
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _productImage(p),
                  const SizedBox(width: 16),
                  Expanded(child: _mainInfo(p)),
                ],
              ),

              const SizedBox(height: 20),

              /// Informasi Utama
              Text(
                'Informasi Utama',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              _infoGrid(p),

              const SizedBox(height: 20),

              /// TIPE PRODUK KHUSUS
              if (p['tipe_produk'] == 'barang') ...[
                Text('Informasi Barang',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 8),
                _barangSection(p),
              ],

              if (p['tipe_produk'] == 'jasa') ...[
                const SizedBox(height: 8),
                _simpleField('Jenis Jasa', p['jenis_jasa']),
              ],

              if (p['tipe_produk'] == 'digital') ...[
                const SizedBox(height: 8),
                _simpleField('Jenis Digital', p['jenis_digital']),
              ],

              const SizedBox(height: 20),

              /// BUTTONS
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Navigasi ke halaman edit (bisa kamu buat sendiri)
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Ubah'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Kembali'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // =================== WIDGETS ===================

  Widget _productImage(Map p) {
  List photos = [];

  if (p['photos'] is List) {
    photos = p['photos'];
  }

  return Container(
    width: 110,
    height: 110,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white24),
    ),
    child: photos.isNotEmpty
        ? ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              "${ApiConfig.baseUrl.replaceAll('/api','')}/storage/${photos[0]}",
              fit: BoxFit.cover,
            ),
          )
        : const Center(
            child: Text('No Image',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
          ),
  );
}


  Widget _mainInfo(Map p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(p['name'],
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Text(p['description'] ?? '',
            style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        Text("Rp ${p['price']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        _badge(p['tipe_produk'], Colors.purple),
        if (p['kategori'] != null) _badge(p['kategori'], Colors.blue),
      ],
    );
  }

  Widget _infoGrid(Map p) {
  return Wrap(
    spacing: 20,
    runSpacing: 10,
    children: [
      _kv('Stok', p['stock']?.toString() ?? '-'),
      _kv('Satuan', p['unit'] ?? '-'),
      _kv('TKDN', p['tkdn'] != null ? '${p['tkdn']}%' : '-'),
      _kv('Izin Edar', p['izin_edar'] ?? '-'),
      _kv(
        'Lead Time',
        p['lead_time_days'] != null
            ? '${p['lead_time_days']} hari'
            : '-',
      ),
    ],
  );
}


  Widget _barangSection(Map p) {
  bool toBool(dynamic v) => v == 1 || v == true;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _kv('Dalam Negeri', toBool(p['is_dalam_negeri']) ? 'Ya' : 'Tidak'),
      _kv('UMK', toBool(p['is_umk']) ? 'Ya' : 'Tidak'),
      _kv('Konsolidasi', toBool(p['is_konsolidasi']) ? 'Ya' : 'Tidak'),
      _kv('Sertifikat TKDN', toBool(p['is_tkdn_sertifikat']) ? 'Ya' : 'Tidak'),
    ],
  );
}


  Widget _kv(String k, dynamic v) {
  final value = (v == null || v.toString().isEmpty) ? '-' : v.toString();

  return Text.rich(
    TextSpan(
      children: [
        TextSpan(
          text: "$k: ",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        TextSpan(
          text: value,
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    ),
  );
}


  Widget _simpleField(String label, dynamic value) {
    return Text("$label: ${value ?? '-'}", style: const TextStyle(color: Colors.white70));
  }

  Widget _badge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(text.toUpperCase(), style: TextStyle(color: color, fontSize: 11)),
    );
  }
}
