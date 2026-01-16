import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; 
import '../layouts/vendor_layout.dart';
import '../services/product_service.dart';


class ProductFormPage extends StatefulWidget {
  final Map<String, dynamic>? product;

  const ProductFormPage({
    super.key,
    this.product,
  });

  bool get isEdit => product != null;

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}
class _ProductFormPageState extends State<ProductFormPage> {
@override
void initState() {
  super.initState();

  if (widget.isEdit) {
    final p = widget.product!;

    // TEXT
    nameC.text = p['name'] ?? '';
    skuC.text = p['sku'] ?? '';
    descC.text = p['description'] ?? '';
    priceC.text = p['price']?.toString() ?? '';
    unitC.text = p['unit'] ?? '';
    stockC.text = p['stock']?.toString() ?? '';
    tkdnC.text = p['tkdn']?.toString() ?? '';
    izinEdarC.text = p['izin_edar'] ?? '';
    leadTimeC.text = p['lead_time_days']?.toString() ?? '';

    // KATEGORI & TIPE
    tipeProduk = p['tipe_produk'] ?? 'barang';
    kategoriBarang = p['kategori'] ?? 'umum';
    jenisJasa = p['jenis_jasa'];
    jenisDigital = p['jenis_digital'];

    // BOOLEAN (INT → BOOL)
    dalamNegeri = p['is_dalam_negeri'] == 1;
    umk = p['is_umk'] == 1;
    konsolidasi = p['is_konsolidasi'] == 1;
    tkdnSertifikat = p['is_tkdn_sertifikat'] == 1;

    // OBAT
    bpomC.text = p['izin_bpom'] ?? '';
    sertifikatCpobC.text = p['sertifikat_cpob'] ?? '';

    // ALKES
    akdC.text = p['no_akd'] ?? '';
    aklC.text = p['no_akl'] ?? '';
    pkrtC.text = p['no_pkrt'] ?? '';
  }
}




  final _formKey = GlobalKey<FormState>();

  // ===== CONTROLLERS =====
  final nameC = TextEditingController();
  final priceC = TextEditingController();
  final unitC = TextEditingController();
  final descC = TextEditingController();
  final stockC = TextEditingController();
  final tkdnC = TextEditingController();
  final izinEdarC = TextEditingController();
  final leadTimeC = TextEditingController();

  final bpomC = TextEditingController();
  final akdC = TextEditingController();
  final aklC = TextEditingController();
  final pkrtC = TextEditingController();
  final skuC = TextEditingController();
final sertifikatCpobC = TextEditingController();
final distributorC = TextEditingController();


  // ===== STATE =====
  String tipeProduk = 'barang';
  String kategoriBarang = 'umum';
  String? jenisJasa;
  String? jenisDigital;

  bool dalamNegeri = false;
  bool umk = false;
  bool konsolidasi = false;
  bool tkdnSertifikat = false;

  List<XFile> photos = [];

  // ===== IMAGE PICKER =====
  final picker = ImagePicker();

  Future pickImages() async {
  final XFile? img = await picker.pickImage(
    source: ImageSource.gallery,
  );

  if (img != null) {
    setState(() => photos.add(img));
  }
}


  // ===== SUBMIT =====
  Future<void> submit() async {
  if (!_formKey.currentState!.validate()) return;

  final payload = {
  'tipe_produk': tipeProduk,
  'kategori': kategoriBarang,
  'name': nameC.text,
  'sku': skuC.text,
  'description': descC.text,
  'price': priceC.text,
  'unit': unitC.text,
  'stock': stockC.text,
  'tkdn': tkdnC.text,
  'izin_edar': izinEdarC.text,
  'lead_time_days': leadTimeC.text,

  // 🔥 BOOLEAN → INT
  'is_dalam_negeri': dalamNegeri ? 1 : 0,
  'is_umk': umk ? 1 : 0,
  'is_konsolidasi': konsolidasi ? 1 : 0,
  'is_tkdn_sertifikat': tkdnSertifikat ? 1 : 0,

  // OBAT
  'izin_bpom': bpomC.text,
  'sertifikat_cpob': sertifikatCpobC.text,

  // ALKES
  'no_akd': akdC.text,
  'no_akl': aklC.text,
  'no_pkrt': pkrtC.text,

  // JASA & DIGITAL
  'jenis_jasa': jenisJasa,
  'jenis_digital': jenisDigital,
};


  try {
    if (widget.isEdit) {
  await ProductService.updateProduct(
    widget.product!['id'],
    payload,
  );
} else {
  await ProductService.createProduct(payload);
}


    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produk berhasil disimpan')),
    );

    Navigator.pop(context); // balik ke list
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal simpan produk: $e')),
    );
  }
}

  // ================= UI =================

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
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
  widget.isEdit ? 'Ubah Produk' : 'Tambah Produk',
  style: const TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  ),
),

              const SizedBox(height: 16),

              _card([
                _dropdown(
                  label: 'Tipe Produk',
                  value: tipeProduk,
                  items: const ['barang', 'jasa', 'digital'],
                  onChanged: (v) => setState(() => tipeProduk = v),
                ),

                _input('Nama Produk', nameC, required: true),

                if (tipeProduk == 'barang') ..._formBarang(),
                if (tipeProduk == 'jasa') ..._formJasa(),
                if (tipeProduk == 'digital') ..._formDigital(),

                Row(
                  children: [
                    Expanded(child: _input('Harga', priceC, number: true)),
                    const SizedBox(width: 10),
                    Expanded(child: _input('Satuan', unitC)),
                  ],
                ),

                _input('Deskripsi', descC, maxLines: 4),
                Row(
                  children: [
                    Expanded(child: _input('Stok', stockC, number: true)),
                    const SizedBox(width: 10),
                    Expanded(child: _input('TKDN (%)', tkdnC, number: true)),
                  ],
                ),

                Row(
                  children: [
                    Expanded(child: _input('Izin Edar', izinEdarC)),
                    const SizedBox(width: 10),
                    Expanded(child: _input('Lead Time (hari)', leadTimeC, number: true)),
                  ],
                ),

                const SizedBox(height: 12),
                _photoPicker(),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(widget.isEdit ? 'Update' : 'Simpan'),

                      ),
                    ),
                    const SizedBox(width: 10),
Expanded(
  child: OutlinedButton(
    onPressed: () => Navigator.pop(context),
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.white, // warna teks
      side: const BorderSide(color: Colors.white), // warna border (opsional)
    ),
    child: const Text('Batal'),
  ),
),

                  ],
                )
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // ================= SECTIONS =================

  List<Widget> _formBarang() => [
        _dropdown(
          label: 'Kategori Barang',
          value: kategoriBarang,
          items: const ['umum', 'obat', 'alkes'],
          onChanged: (v) => setState(() => kategoriBarang = v),
        ),

        Wrap(
          spacing: 10,
          children: [
            _check('Dalam Negeri', dalamNegeri, (v) => setState(() => dalamNegeri = v)),
            _check('UMK', umk, (v) => setState(() => umk = v)),
            _check('Konsolidasi', konsolidasi, (v) => setState(() => konsolidasi = v)),
            _check('TKDN Sertifikat', tkdnSertifikat, (v) => setState(() => tkdnSertifikat = v)),
          ],
        ),
if (kategoriBarang == 'obat') ...[
  _input('Nomor BPOM', bpomC),
  _input('Sertifikat CPOB', sertifikatCpobC),
],
        if (kategoriBarang == 'alkes') ...[
          _input('Nomor AKD', akdC),
          _input('Nomor AKL', aklC),
          _input('Nomor PKRT', pkrtC),
        ],
      ];

  List<Widget> _formJasa() => [
        _dropdown(
          label: 'Jenis Jasa',
          value: jenisJasa,
          items: const ['konstruksi', 'non_konstruksi', 'konsultansi'],
          onChanged: (v) => setState(() => jenisJasa = v),
        ),
      ];

  List<Widget> _formDigital() => [
        _dropdown(
          label: 'Jenis Produk Digital',
          value: jenisDigital,
          items: const [
            'software_lisensi',
            'software_open_source',
            'cloud_service',
            'it_service'
          ],
          onChanged: (v) => setState(() => jenisDigital = v),
        ),
      ];

  // ================= COMPONENTS =================

  Widget _card(List<Widget> children) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children
              .map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: e,
                  ))
              .toList(),
        ),
      );

  Widget _input(String label, TextEditingController c,
      {bool required = false, bool number = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFBFDBFE))),
        const SizedBox(height: 4),
        TextFormField(
          controller: c,
          maxLines: maxLines,
          keyboardType: number ? TextInputType.number : TextInputType.text,
          validator: required ? (v) => v!.isEmpty ? 'Wajib diisi' : null : null,
          style: const TextStyle(color: Colors.white),
          decoration: _dec(),
        ),
      ],
    );
  }

  Widget _dropdown({
    required String label,
    required dynamic value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFBFDBFE))),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
  style: const TextStyle(color: Colors.white),
          value: value,
          items: items
              .map((e) => DropdownMenuItem(
  value: e,
  child: Text(
    e,
    style: const TextStyle(color: Colors.white),
  ),
)
)
              .toList(),
          onChanged: (v) => onChanged(v!),
          dropdownColor: const Color(0xFF1A1F4A),
          decoration: _dec(),
        ),
      ],
    );
  }

  Widget _check(String label, bool val, Function(bool) onChanged) {
    return FilterChip(
      label: Text(label),
      selected: val,
      onSelected: onChanged,
      selectedColor: Colors.blue,
    );
  }

 Widget _photoPicker() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Foto Produk',
        style: TextStyle(color: Color(0xFFBFDBFE)),
      ),
      const SizedBox(height: 6),
      Wrap(
        spacing: 8,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque, // 🔥 INI KUNCINYA
            onTap: () async {
              debugPrint('KLIK FOTO MASUK');
              await pickImages();
            },
            child: Container(
              width: 80,
              height: 80,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
          ...photos.map(
            (p) => ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(p.path),
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    ],
  );
}


  InputDecoration _dec() => InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white24),
        ),
      );
}
