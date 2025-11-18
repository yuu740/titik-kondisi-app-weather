import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'main_screen.dart';
import 'onboarding_screen.dart';
import '../provider/subs_provider.dart';
import '../provider/theme_provider.dart';
import '../services/ad_service.dart';

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
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _adManager.loadInterstitialAd();

    _fadeController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutQuart),
    );

    _checkLoginAndProceed();
  }

  Future<void> _checkLoginAndProceed() async {
    const storage = FlutterSecureStorage();
    // final token = await storage.read(key: 'auth_token');
    final token = await storage.read(key: 'session_token');

    setState(() {
      _isLoggedIn = token != null;
      _isLoading = false;
    });

    _fadeController.forward();

    if (_isLoggedIn) {
      await Future.delayed(const Duration(seconds: 3));
      _proceedToMainApp();
    } else {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) _slideController.forward();
    }
  }

  void _proceedToMainApp() async {
    if (!mounted) return;

    final navigator = Navigator.of(context);
    final subProvider = context.read<SubscriptionProvider>();
    final prefs = await SharedPreferences.getInstance();
    final bool isFirstRun = prefs.getBool('isFirstRunAfterLogin') ?? true;

    void navigate() {
      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (_) => isFirstRun ? const OnboardingScreen() : const MainScreen(),
        ),
      );
    }

    if (subProvider.isPro) {
      navigate();
    } else {
      _adManager.showInterstitialAd(onAdDismissed: navigate);
    }
  }

  void _navigateToLogin() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
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
            colors: isDarkMode 
                ? [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)] // Deep Space
                : [Colors.blue[100]!, Colors.white],
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
                    Container(
                      height: 150, 
                      width: 150,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('assets/images/logo.png'), 
                          fit: BoxFit.contain,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'From air quality to astral clarity',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: isDarkMode ? Colors.white70 : Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 3),
              if (!_isLoading && !_isLoggedIn)
                SlideTransition(
                  position: _slideAnimation,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 5,
                    ),
                    onPressed: _navigateToLogin,
                    child: const Text('Login or Sign Up', style: TextStyle(fontSize: 16)),
                  ),
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}