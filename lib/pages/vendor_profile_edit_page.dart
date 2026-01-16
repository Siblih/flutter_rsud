import 'package:flutter/material.dart';
import '../services/vendor_service.dart';

class VendorProfileEditPage extends StatefulWidget {
  const VendorProfileEditPage({super.key});

  @override
  State<VendorProfileEditPage> createState() => _VendorProfileEditPageState();
}

class _VendorProfileEditPageState extends State<VendorProfileEditPage> {
  final _formKey = GlobalKey<FormState>();

  final companyController = TextEditingController();
  final bidangController = TextEditingController();
  final nibController = TextEditingController();
  final siupController = TextEditingController();
  final npwpController = TextEditingController();
  final alamatController = TextEditingController();
  final contactController = TextEditingController();
  final phoneController = TextEditingController();
  final descController = TextEditingController();

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await VendorService.fetchProfile();

    companyController.text = data['company_name'] ?? '';
    bidangController.text = data['bidang_usaha'] ?? '';
    nibController.text = data['nib'] ?? '';
    siupController.text = data['siup'] ?? '';
    npwpController.text = data['npwp'] ?? '';
    alamatController.text = data['alamat'] ?? '';
    contactController.text = data['contact_person'] ?? '';
    phoneController.text = data['phone'] ?? '';
    descController.text = data['description'] ?? '';

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('✏️ Edit Profil Vendor'),
        backgroundColor: const Color(0xFF1A1F4A),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
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
              _input('🏢 Nama Perusahaan', companyController),
              _input('💼 Bidang Usaha', bidangController),
              _input('🧾 NIB', nibController),
              _input('📑 SIUP', siupController),
              _input('💳 NPWP', npwpController),
              _input('📍 Alamat', alamatController, maxLines: 2),
              _input('👤 Contact Person', contactController),
              _input('📞 Telepon', phoneController),
              _input('📝 Deskripsi', descController, maxLines: 3),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;

                  // 🔥 nanti panggil API update
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('💾 Simpan Profil'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.blueAccent),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
