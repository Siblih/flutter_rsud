import 'package:flutter/material.dart';
import '../layouts/vendor_layout.dart';
import '../services/product_service.dart';
import 'product_detail_page.dart';
import 'product_form_page.dart';



class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List products = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => loading = true);
    try {
      final data = await ProductService.fetchProducts();
      setState(() {
        products = data;
        loading = false;
      });
    } catch (_) {
      setState(() => loading = false);
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'verified':
        return Colors.greenAccent;
      case 'rejected':
        return Colors.redAccent;
      default:
        return Colors.amberAccent;
    }
  }

  String formatShortPrice(dynamic price) {
    if (price == null) return '0';
    final num value = price is String ? num.tryParse(price) ?? 0 : price;

    if (value >= 1e12) return '${(value / 1e12).toStringAsFixed(1)} T';
    if (value >= 1e9) return '${(value / 1e9).toStringAsFixed(1)} M';
    if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(1)} jt';
    if (value >= 1e3) return '${(value / 1e3).toStringAsFixed(1)} rb';
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return VendorLayout(
      currentIndex: 1,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1F4A), Color(0xFF2B3370)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '📦 Produk Saya',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                     ElevatedButton(
  onPressed: () async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProductFormPage(), // CREATE
      ),
    );
    if (res == true) _loadProducts();
  },
  child: const Text('+ Tambah'),
),


                    ],
                  ),
                  const SizedBox(height: 16),

                  if (products.isEmpty)
                    const Center(
                      child: Text('Belum ada produk',
                          style: TextStyle(color: Colors.blueAccent)),
                    ),

                  ...products.map((p) => _productCard(p)).toList(),
                ],
              ),
      ),
    );
  }

  Widget _productCard(Map p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FOTO
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.hardEdge,
            child: p['photo_url'] != null
                ? Image.network(p['photo_url'], fit: BoxFit.cover)
                : const Icon(Icons.image, color: Colors.white54),
          ),
          const SizedBox(width: 12),

          // INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p['name'],
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  p['description'] ?? '-',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Color(0xFFBFDBFE), fontSize: 12),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    const Text('Status: ',
                        style: TextStyle(
                            color: Color(0xFFBFDBFE), fontSize: 12)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor(p['status']).withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(p['status'],
                          style: TextStyle(
                              fontSize: 11,
                              color: statusColor(p['status']))),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

               Row(
  children: [
    GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(
              productId: p['id'], // 🔥 pastikan ini ID produk
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'Detail',
          style: TextStyle(fontSize: 11, color: Colors.white),
        ),
      ),
    ),
    const SizedBox(width: 6),
   _actionBtn(
  'Ubah',
  Colors.grey,
  () async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductFormPage(
          product: Map<String, dynamic>.from(p),
        ),
      ),
    );

    if (res == true) {
      _loadProducts(); // 🔥 refresh setelah update
    }
  },
),




    const SizedBox(width: 6),
    _actionBtn('Hapus', Colors.red, () => _deleteProduct(p['id'])),
  ],
)

              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rp ${formatShortPrice(p['price'])}',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(p['unit'] ?? '-',
                  style:
                      const TextStyle(color: Colors.white60, fontSize: 11)),
            ],
          )
        ],
      ),
    );
  }

  Widget _actionBtn(String text, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
        child:
            Text(text, style: const TextStyle(fontSize: 11, color: Colors.white)),
      ),
    );
  }

  void _showDetail(Map p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(p['name']),
        content: Text(p['description'] ?? '-'),
      ),
    );
  }

  void _deleteProduct(int id) async {
    final ok = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: const Text('Yakin hapus produk ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus')),
        ],
      ),
    );

    if (ok == true) {
      await ProductService.deleteProduct(id);
      _loadProducts();
    }
  }

  void _openForm(Map? product) {
    final name = TextEditingController(text: product?['name']);
    final desc = TextEditingController(text: product?['description']);
    final price =
        TextEditingController(text: product?['price']?.toString());
    final unit = TextEditingController(text: product?['unit']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(product == null ? 'Tambah Produk' : 'Ubah Produk'),
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Nama')),
            TextField(controller: desc, decoration: const InputDecoration(labelText: 'Deskripsi')),
            TextField(controller: price, decoration: const InputDecoration(labelText: 'Harga')),
            TextField(controller: unit, decoration: const InputDecoration(labelText: 'Unit')),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final data = {
                  'name': name.text,
                  'description': desc.text,
                  'price': price.text,
                  'unit': unit.text,
                };

                if (product == null) {
                 await ProductService.createProduct(data);

                } else {
                  await ProductService.updateProduct(product['id'], data);
                }

                Navigator.pop(context);
                _loadProducts();
              },
              child: const Text('Simpan'),
            )
          ],
        ),
      ),
    );
  }
}
