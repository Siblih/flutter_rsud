import 'package:flutter/material.dart';
import '../services/account_service.dart';

class VendorSettingsPage extends StatefulWidget {
  const VendorSettingsPage({super.key});

  @override
  State<VendorSettingsPage> createState() => _VendorSettingsPageState();
}

class _VendorSettingsPageState extends State<VendorSettingsPage> {
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool loading = false;

  Future<void> submit() async {
    if (_newCtrl.text != _confirmCtrl.text) {
      _snack('Konfirmasi password tidak cocok');
      return;
    }

    setState(() => loading = true);
    try {
      await AccountService.updatePassword(
        oldPassword: _oldCtrl.text,
        newPassword: _newCtrl.text,
        confirmPassword: _confirmCtrl.text,
      );
      _snack('Password berhasil diubah');
      _oldCtrl.clear();
      _newCtrl.clear();
      _confirmCtrl.clear();
    } catch (e) {
      _snack(e.toString());
    }
    setState(() => loading = false);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1F4A),
      appBar: AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  centerTitle: true,

  // 🔙 TOMBOL KEMBALI
  leading: Padding(
    padding: const EdgeInsets.only(left: 12),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: Colors.white,
        ),
      ),
    ),
  ),

  // 🧠 JUDUL
  title: const Text(
    'Pengaturan Akun',
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      letterSpacing: 0.4,
    ),
  ),
),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            children: [
              _input('Password Lama', _oldCtrl, obscure: true),
              _input('Password Baru', _newCtrl, obscure: true),
              _input('Konfirmasi Password', _confirmCtrl, obscure: true),
              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: loading ? null : submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('🔐 Ubah Password'),
              ),

              const Divider(height: 32, color: Colors.white30),

              TextButton(
                onPressed: () async {
                  await AccountService.logout();
                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (_) => false,
                    );
                  }
                },
                child: const Text(
                  '🚪 Keluar dari Akun',
                  style: TextStyle(color: Colors.redAccent),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController c,
      {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.blueAccent),
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
