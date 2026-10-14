import 'package:flutter/material.dart';
import 'package:kaloriku/view/screen/bottom_navbar.dart';
import 'package:kaloriku/services/auth_manager.dart';
import 'package:kaloriku/view/screen/home_page.dart'; // ✅ Tambahkan HomePage
import 'package:kaloriku/view/screen/login_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    
    // ✅ Pastikan cek login hanya dijalankan setelah widget siap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAuthStatus();
    });
  }

  /// Fungsi untuk mengecek status login setelah HomePage ditampilkan
  Future<void> checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2)); // ✅ Tunggu sebentar
    bool isAuthenticated = await AuthManager.isLoggedIn();
    
    if (!isAuthenticated && mounted) { // ✅ Pastikan widget masih tersedia
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KaloriKu',
      home: HomePage(), // ✅ Awali dengan HomePage dulu
    );
  }
}
