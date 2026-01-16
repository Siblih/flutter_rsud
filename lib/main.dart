import 'package:flutter/material.dart';

// PAGES
import 'pages/welcome_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'pages/product_page.dart';
import 'pages/product_form_page.dart';
import 'pages/product_detail_page.dart';
import 'pages/vendor_profile_page.dart';
import 'pages/vendor_profile_edit_page.dart';
import 'pages/vendor_pengadaan_page.dart';
import 'pages/vendor_pengadaan_detail_page.dart';
import 'pages/vendor_kontrak.dart';
import 'pages/vendor_kontrak_detail_page.dart';
import 'pages/vendor_kontrak_upload_page.dart';
import 'pages/vendor_settings_page.dart';
import 'pages/vendor_document_page.dart';


// SERVICES
import 'services/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getStartPage() async {
    final token = await AuthService.getToken();

    if (token != null && token.isNotEmpty) {
      return HomePage();
    }
    return const WelcomePage();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      // ROUTE STATIS
      routes: {
        '/login': (_) => LoginPage(),
        '/register': (_) => RegisterPage(),
        '/home': (_) => HomePage(),
        '/produk': (_) => const ProductPage(),
        '/produk/tambah': (_) => const ProductFormPage(),
        '/vendor-profile': (_) => const VendorProfilePage(),
        '/vendor-profile/edit': (_) => const VendorProfileEditPage(),
        '/vendor-pengadaan': (_) => const VendorPengadaanPage(),
        '/vendor-pengadaan/detail': (context) => const VendorPengadaanDetailPage(),
        '/vendor/kontrak': (context) => const VendorKontrakPage(),
        '/vendor-kontrak/detail': (context) => const VendorKontrakDetailPage(),
        '/settings': (context) => const VendorSettingsPage(),
        '/vendor-documents': (context) => const VendorDocumentPage(),


        '/vendor-kontrak/upload': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;

          // 🔒 VALIDASI BIAR GAK MELEDAK
          if (args is! int) {
            throw Exception(
              'vendor-kontrak/upload BUTUH int kontrakId, '
              'tapi dapat: ${args.runtimeType}',
            );
          }

          return VendorKontrakUploadPage(
            kontrakId: args,
          );
        },
      },


      // ROUTE DINAMIS DETAIL
      onGenerateRoute: (settings) {
        if (settings.name == '/produk/detail') {
          final int productId = settings.arguments as int;

          return MaterialPageRoute(
            builder: (_) => ProductDetailPage(productId: productId),
          );
        }
        return null;
      },

      // START PAGE
      home: FutureBuilder<Widget>(
        future: _getStartPage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.data!;
        },
      ),
    );
  }
}
