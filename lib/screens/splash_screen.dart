import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titik_kondisi/provider/location_provider.dart';
import 'main_screen.dart';
import 'onboarding_screen.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeAppAndNavigate();
  }

  Future<void> _initializeAppAndNavigate() async {
    // Inisialisasi awal
    await Provider.of<LocationProvider>(context, listen: false).fetchInitialLocation();
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Cek status login
    const storage = FlutterSecureStorage();
    final String? token = await storage.read(key: 'auth_token');

    if (token != null) {
      // KASUS 1: Pengguna SUDAH LOGIN
      final prefs = await SharedPreferences.getInstance();
      final bool isFirstRunAfterLogin = prefs.getBool('isFirstRunAfterLogin') ?? true;

      if (isFirstRunAfterLogin) {
        // Jika ini login pertama, tampilkan halaman preferensi
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      } else {
        // Jika sudah pernah login & set preferensi, langsung ke dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }
    } else {
      // KASUS 2: Pengguna BELUM LOGIN
      // Arahkan ke halaman selamat datang dengan tombol login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Memuat...'),
          ],
        ),
      ),
    );
  }
}