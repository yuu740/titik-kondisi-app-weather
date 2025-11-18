import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../provider/location_provider.dart';
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
    // 1. Inisialisasi Lokasi
    await Provider.of<LocationProvider>(context, listen: false).fetchInitialLocation();
    
    // Simulasi loading minimal 2 detik agar logo terlihat
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // 2. Cek Session (Perbaikan Key di sini)
    const storage = FlutterSecureStorage();
    // GUNAKAN 'session_token' AGAR COCOK DENGAN AUTH PROVIDER
    final String? token = await storage.read(key: 'session_token'); 

    if (token != null) {
      final prefs = await SharedPreferences.getInstance();

      final bool isFirstRunAfterLogin = prefs.getBool('isFirstRunAfterLogin') ?? true;

      if (isFirstRunAfterLogin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    } else {
      // --- KASUS: BELUM LOGIN ---
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
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
}