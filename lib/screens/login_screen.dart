import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titik_kondisi/screens/dashboard_screen.dart';
import '../provider/auth_provider.dart'; 
import '../provider/subs_provider.dart';
import '../services/ad_service.dart';
import 'onboarding_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final AdManager _adManager = AdManager();
  
  bool _isLoginMode = true; 
  
  @override
  void initState() {
    super.initState();
    _adManager.loadInterstitialAd();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Tutup keyboard
    FocusScope.of(context).unfocus();

    // Gunakan AuthProvider, bukan AuthService langsung
    final authProvider = context.read<AuthProvider>();

    try {
      if (_isLoginMode) {
        await authProvider.login(
          _emailController.text.trim(),
          _passwordController.text,
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isFirstRunAfterLogin', false);
      } else {
        await authProvider.register(
          _emailController.text.trim(),
          _passwordController.text,
          _confirmPasswordController.text,
        );
      }

      // --- JIKA SUKSES (Tidak ada error) ---
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstRunAfterLogin', true);

      if (!mounted) return;

      final subProvider = context.read<SubscriptionProvider>();
      final navigator = Navigator.of(context);

      void navigateToNext() async {
       // Cek ulang preference yang barusan kita set
       final prefs = await SharedPreferences.getInstance();
       final bool isFirstRun = prefs.getBool('isFirstRunAfterLogin') ?? false;

       if (isFirstRun) {
          // Jika Register -> Ke Onboarding
          navigator.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            (route) => false,
          );
       } else {
          // Jika Login -> Langsung ke MainScreen (Dashboard)
          navigator.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
            (route) => false,
          );
       }
    }
      if (subProvider.isPro) {
        navigateToNext();
      } else {
        _adManager.showInterstitialAd(onAdDismissed: navigateToNext);
      }

    } catch (e) {
      // --- JIKA GAGAL (Tampilkan Error dari Provider/API) ---
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil loading state dari provider
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
        appBar: AppBar(title: Text(_isLoginMode ? 'Login' : 'Sign Up')),      
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLoginMode ? 'Welcome Back!' : 'Create New Account',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => (value == null || !value.contains('@')) ? 'Invalid email' : null,                  ),
                  const SizedBox(height: 16),
                
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                    obscureText: true,
                    validator: (value) => (value == null || value.length < 8) ? 'Password must be at least 8 characters' : null,                  
                  ),

                  if (!_isLoginMode) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: const InputDecoration(labelText: 'Confirm Password', border: OutlineInputBorder()),                      
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        if (value != _passwordController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                  ],

                  const SizedBox(height: 24),
                
                  isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          onPressed: _submitForm,
                          child: Text(_isLoginMode ? 'Login' : 'Sign Up'),
                        ),
                  
                  const SizedBox(height: 16),
                
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLoginMode = !_isLoginMode; 
                      _formKey.currentState?.reset(); 
                      _emailController.clear();
                      _passwordController.clear();
                      _confirmPasswordController.clear();
                    });
                  },
                  child: Text(_isLoginMode 
                    ? "Don't have an account? Sign Up" 
                    : "Already have an account? Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}