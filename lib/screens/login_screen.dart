// screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../provider/subs_provider.dart';
import '../services/ad_service.dart';
import '../services/fake_auth_service.dart';
import 'onboarding_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final AdManager _adManager = AdManager();
  bool _isLoginMode = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _adManager.loadInterstitialAd();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);

    // --- SIMULASI PROSES AUTENTIKASI ---
    await context.read<FakeAuthService>().login();
    await const FlutterSecureStorage().write(key: 'auth_token', value: 'dummy_user_token_123');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstRunAfterLogin', true);

    await Future.delayed(const Duration(seconds: 1)); // Jeda palsu
    if (!mounted) return;

    final subProvider = context.read<SubscriptionProvider>();
    final navigator = Navigator.of(context);

    void navigateToOnboarding() {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        (route) => false,
      );
    }

    if (subProvider.isPro) {
      navigateToOnboarding();
    } else {
      _adManager.showInterstitialAd(onAdDismissed: navigateToOnboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLoginMode ? 'Masuk' : 'Daftar')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isLoginMode ? 'Selamat Datang Kembali!' : 'Buat Akun Baru',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => (value == null || !value.contains('@')) ? 'Email tidak valid' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                  obscureText: true,
                  validator: (value) => (value == null || value.length < 6) ? 'Password minimal 6 karakter' : null,
                ),
                if (!_isLoginMode) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Konfirmasi Password', border: OutlineInputBorder()),
                    obscureText: true,
                    validator: (value) => (value == null || value.length < 6) ? 'Password minimal 6 karakter' : null,
                  ),
                ],
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: _submitForm,
                        child: Text(_isLoginMode ? 'Masuk' : 'Daftar'),
                      ),
                TextButton(
                  onPressed: () => setState(() => _isLoginMode = !_isLoginMode),
                  child: Text(_isLoginMode ? 'Belum punya akun? Daftar' : 'Sudah punya akun? Masuk'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}