import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../pages/login_page.dart';

class VendorLayout extends StatefulWidget {
  final Widget child;
  final int currentIndex;

  const VendorLayout({
    super.key,
    required this.child,
    this.currentIndex = 0,
  });

  @override
  State<VendorLayout> createState() => _VendorLayoutState();
}

class _VendorLayoutState extends State<VendorLayout> {
  String vendorName = 'Vendor';

  static const double _headerHeight = 120;
  static const double _footerHeight = 80;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getUser();
    if (user != null && mounted) {
      setState(() {
        vendorName = user['name'] ?? 'Vendor';
      });
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF4FF),
      body: Stack(
        children: [
          // ================= CONTENT (INI YANG BOLEH DIKLIK) =================
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(
                top: _headerHeight,
                bottom: _footerHeight,
              ),
              child: widget.child,
            ),
          ),

          // ================= HEADER (TIDAK BOLEH NANGKAP TAP) =================
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer( // 🔥 FIX UTAMA
              ignoring: false,
              child: _Glass(
                height: _headerHeight,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Avatar + Brand
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white,
                              child: Text(
                                vendorName.isNotEmpty
                                    ? vendorName[0].toUpperCase()
                                    : 'V',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1D4ED8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'PERSUD Bangil',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  vendorName,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Logout (tampilan saja, tap dinonaktifkan)
                        GestureDetector(
  onTap: _logout, // 🔥 INI YANG KAMU CARI DARI TADI
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.red.shade500,
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Text(
      'Logout',
      style: TextStyle(
        fontSize: 12,
        color: Colors.white,
      ),
    ),
  ),
),

                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ================= FOOTER (BOLEH DIKLIK) =================
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: false,
              child: _Glass(
                height: _footerHeight,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _NavItem(
                      icon: Icons.home,
                      label: 'Dashboard',
                      active: widget.currentIndex == 0,
                      onTap: () =>
                          Navigator.pushReplacementNamed(context, '/home'),
                    ),
                    _NavItem(
                      icon: Icons.inventory_2,
                      label: 'Produk',
                      active: widget.currentIndex == 1,
                      onTap: () =>
                          Navigator.pushReplacementNamed(context, '/produk'),
                    ),
                    _NavItem(
                      icon: Icons.description,
                      label: 'Kontrak',
                      active: widget.currentIndex == 2,
                      onTap: () =>
                          Navigator.pushReplacementNamed(context, '/vendor/kontrak'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= GLASS =================
class _Glass extends StatelessWidget {
  final Widget child;
  final double height;
  final BorderRadius borderRadius;

  const _Glass({
    required this.child,
    required this.height,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 12, 69, 226).withOpacity(0.35),
            borderRadius: borderRadius,
            border: Border.all(color: Colors.white24),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ================= NAV ITEM =================
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = active
        ? const Color.fromARGB(255, 39, 119, 184)
        : const Color.fromARGB(255, 21, 82, 162);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight:
                    active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
