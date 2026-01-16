import 'package:flutter/material.dart';
import '../layouts/vendor_layout.dart';
import '../services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String vendorName = 'Vendor';
  String verificationStatus = 'Belum diverifikasi';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
  final profile = await AuthService.fetchProfile();

  if (!mounted) return;
  setState(() {
    vendorName = profile['name'] ?? 'Vendor';
    verificationStatus =
        profile['verification_status'] ?? 'Belum diverifikasi';
  });
}


  Color _statusColor() {
    switch (verificationStatus) {
      case 'verified':
        return Colors.greenAccent;
      case 'rejected':
        return Colors.redAccent;
      default:
        return Colors.amberAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return VendorLayout(
      currentIndex: 0,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1F4A),
              Color(0xFF2B3370),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
          child: Column(
            children: [
              // ===== HEADER =====
              const Text(
                '📦 Dashboard Vendor',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Akses cepat ke semua fitur vendor',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFFBFDBFE),
                ),
              ),

              const SizedBox(height: 24),

              // ===== PROFIL VENDOR =====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, $vendorName',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFDBEAFE),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text(
                          'Status: ',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          verificationStatus,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _statusColor(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ===== MENU GRID =====
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _MenuCard(
                    emoji: '🧾',
                    label: 'Pengadaan Aktif',
                    onTap: () {
                      Navigator.pushNamed(context, '/vendor-pengadaan');
                    },
                  ),
                 _MenuCard(
  emoji: '🏢',
  label: 'Profil Perusahaan',
  onTap: () {
    Navigator.pushNamed(context, '/vendor-profile');
  },
),

                  _MenuCard(
                    emoji: '📤',
                    label: 'Upload Dokumen',
                    onTap: () {
                      Navigator.pushNamed(context, '/vendor-documents');
                    },
                  ),
                  _MenuCard(
                    emoji: '⚙️',
                    label: 'Pengaturan',
                    isWide: true,
                    onTap: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== MENU CARD =====
class _MenuCard extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;
  final bool isWide;

  const _MenuCard({
    required this.emoji,
    required this.label,
    required this.onTap,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return GridTile(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFDBEAFE),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
