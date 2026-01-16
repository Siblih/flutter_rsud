import 'package:flutter/material.dart';
import '../layouts/vendor_layout.dart';
import '../services/vendor_service.dart';
import '../services/auth_service.dart';

class VendorProfilePage extends StatefulWidget {
  const VendorProfilePage({super.key});

  @override
  State<VendorProfilePage> createState() => _VendorProfilePageState();
}

class _VendorProfilePageState extends State<VendorProfilePage> {
  Map<String, dynamic>? profile;
  bool loading = true;

  @override
void initState() {
  super.initState();
  _init();
}

Future<void> _init() async {
  final token = await AuthService.getToken();

  if (token == null || token.isEmpty) {
    Navigator.pushReplacementNamed(context, '/login');
    return;
  }

  await _loadProfile();
}


 Future<void> _loadProfile() async {
  try {
    final data = await VendorService.fetchProfile();
    setState(() {
      profile = data;
      loading = false;
    });
  } catch (e) {
  setState(() {
    loading = false;
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Gagal memuat profil')),
  );
}

}



  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (profile == null) {
      return const Scaffold(
        body: Center(child: Text('Gagal memuat profil')),
      );
    }

    return VendorLayout(
      currentIndex: 3,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1F4A), Color(0xFF2B3370)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          children: [
            /// ===== HEADER =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Profil Perusahaan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _editButton(context),
              ],
            ),

            const SizedBox(height: 16),

            /// ===== PROFILE CARD =====
            _glassCard(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _companyHeader(),
                  const SizedBox(height: 12),
                  _infoRow('🧾 NIB', profile!['nib']),
                  _infoRow('📑 SIUP', profile!['siup']),
                  _infoRow('💳 NPWP', profile!['npwp']),
                  _infoRow('📍 Alamat', profile!['alamat'], multiline: true),
                  _infoRow('👤 Contact Person', profile!['contact_person']),
                  _infoRow('📞 Telepon', profile!['phone']),
                  const SizedBox(height: 12),
                  _descriptionBox(),
                  const SizedBox(height: 16),
                  _verificationStatus(),
                ],
              ),
            ),

            const SizedBox(height: 20),

           /// ===== DOCUMENTS =====
_documentsSection(),

const SizedBox(height: 24),

/// ===== BUTTON =====
/// ===== BUTTON =====
ElevatedButton(
  onPressed: () {
    final status = profile?['verification_status'];
    final bool isVerified = status == 'verified';

    if (isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profil sudah diverifikasi admin dan tidak dapat diubah',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // ✅ BELUM VERIFIED
    Navigator.pushNamed(context, '/vendor-profile/edit');
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: profile?['verification_status'] == 'verified'
        ? Colors.grey
        : Colors.blue,
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
  ),
  child: Text(
    '✏️ Ubah Profil',
    style: TextStyle(
      color: profile?['verification_status'] == 'verified'
          ? Colors.white70
          : Colors.white,
    ),
  ),
),


          ],
        ),
      ),
    );
  }

  // ================= HEADER =================

  Widget _companyHeader() {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.25),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.business, color: Colors.white, size: 30),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              profile!['company_name'] ?? 'Belum diisi',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              profile!['bidang_usaha'] ?? '-',
              style: const TextStyle(color: Colors.blueAccent),
            ),
          ],
        ),
      ],
    );
  }

  // ================= INFO =================

  Widget _infoRow(String label, dynamic value, {bool multiline = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        crossAxisAlignment:
            multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.blueAccent)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value ?? '-',
              textAlign: TextAlign.right,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ================= DESCRIPTION =================

  Widget _descriptionBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📝 Deskripsi / Pengalaman',
            style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            profile!['description'] ??
                'Belum ada deskripsi perusahaan.',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // ================= VERIFICATION =================

  Widget _verificationStatus() {
    final status = profile!['verification_status'] ?? 'pending';

    Color color = Colors.orange;
    if (status == 'verified') color = Colors.green;
    if (status == 'rejected') color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Status Verifikasi',
              style: TextStyle(color: Colors.blueAccent)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ================= DOCUMENTS =================

  Widget _documentsSection() {
    final docs = profile!['vendor_documents'] ?? [];

    return _glassCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📂 Dokumen Perusahaan',
            style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          if (docs.isEmpty)
            const Center(
              child: Text('📁 Belum ada dokumen',
                  style: TextStyle(color: Colors.white70)),
            ),
          ...docs.take(3).map<Widget>((d) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    d['file_name'] ?? '-',
                    style: const TextStyle(color: Colors.white),
                  ),
                  _docStatus(d['status']),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _docStatus(String? status) {
    Color color = Colors.orange;
    if (status == 'verified') color = Colors.green;
    if (status == 'rejected') color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        (status ?? 'pending').toUpperCase(),
        style: TextStyle(color: color, fontSize: 10),
      ),
    );
  }

  // ================= COMMON =================

  Widget _glassCard(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24),
      ),
      child: child,
    );
  }

  Widget _editButton(BuildContext context) {
  final status = profile?['verification_status'];

  final bool isVerified = status == 'verified';

  return GestureDetector(
    onTap: () {
      if (isVerified) {
        // ❌ SUDAH DIVERIFIKASI → TOLAK EDIT
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Profil sudah diverifikasi admin dan tidak dapat diubah',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      // ✅ BELUM VERIFIED → BOLEH EDIT
      Navigator.pushNamed(context, '/vendor-profile/edit');
    },
    child: Opacity(
      opacity: isVerified ? 0.5 : 1, // visual disabled
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isVerified
              ? Colors.grey.withOpacity(0.2)
              : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white30),
        ),
        child: Text(
          '✏️ Edit',
          style: TextStyle(
            color: isVerified ? Colors.white54 : Colors.white,
            fontSize: 12,
          ),
        ),
      ),
    ),
  );
}

}
