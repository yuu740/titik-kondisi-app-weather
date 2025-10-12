// screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titik_kondisi/provider/location_provider.dart';
import 'main_screen.dart';
import 'onboarding_screen.dart';
import 'welcome_screen.dart'; // Ganti dari WelcomePage ke WelcomeScreen

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
    // 1. Inisialisasi awal (jika ada)
    await Provider.of<LocationProvider>(context, listen: false).fetchInitialLocation();
    await Future.delayed(const Duration(seconds: 2)); // Jeda untuk splash

    if (!mounted) return;

    // 2. Cek status login
    const storage = FlutterSecureStorage();
    final String? token = await storage.read(key: 'auth_token'); // Dummy token check

    if (token != null) {
      // User SUDAH LOGIN
      final prefs = await SharedPreferences.getInstance();
      final bool isFirstRun = prefs.getBool('isFirstRunAfterLogin') ?? true;

      if (isFirstRun) {
        // Jika login pertama kali, arahkan ke Onboarding
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      } else {
        // Jika bukan login pertama kali, langsung ke Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    } else {
      // User BELUM LOGIN, arahkan ke halaman welcome dengan tombol login
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