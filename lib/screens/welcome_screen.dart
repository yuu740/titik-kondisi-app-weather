// screens/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'onboarding_screen.dart';
import '../provider/theme_provider.dart';
import '../provider/subs_provider.dart'; 
import '../services/ad_service.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; // TAMBAHKAN IMPORT INI


class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  final AdManager _adManager = AdManager();
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutQuart),
    );

    _fadeController.forward();
    // Tampilkan tombol setelah animasi utama selesai
    Future.delayed(const Duration(seconds: 2), () {
      if(mounted) _slideController.forward();
    });
    _adManager.loadInterstitialAd();
  }

  Future<void> _handleSignIn() async {
    // --- SIMULASI LOGIN ---
    // Simpan dummy token
    await const FlutterSecureStorage().write(key: 'auth_token', value: 'dummy_user_token_123');
    // Tandai bahwa ini adalah kali pertama setelah login
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstRunAfterLogin', true);

    if (mounted) {
      // Arahkan ke Onboarding setelah berhasil login
      final subProvider = context.read<SubscriptionProvider>();
      if (!subProvider.isPro) {
        _adManager.showInterstitialAd();
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(seconds: 5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode ? [Colors.purple[900]!, Colors.black] : [Colors.blue[200]!, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Icon(
                      isDarkMode ? Icons.nights_stay : Icons.wb_sunny,
                      size: 100,
                      color: isDarkMode ? Colors.white : Colors.yellow[700],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'TitikKondisi',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Prakiraan cuaca akurat dengan info langit malam terkini.',
                      style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 3),
              SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      onPressed: _handleSignIn,
                      child: const Text('Masuk dengan Akun', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                         // Arahkan langsung ke Onboarding/MainScreen tanpa login
                         // Untuk sekarang kita samakan dengan login
                         _handleSignIn();
                      },
                      child: const Text('Lanjutkan tanpa akun'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}