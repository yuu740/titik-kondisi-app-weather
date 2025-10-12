import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart'; // Tambahkan package ini
import './onboarding_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      // 1. Panggil Google Sign-In
      // final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      // final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      // final String? idToken = googleAuth?.idToken;

      // 2. Kirim idToken ke backend Go Anda
      // final response = await http.post('https://api.anda.com/v1/auth/google', body: {'token': idToken});

      // 3. Jika berhasil, simpan token dari backend
      // final String appToken = json.decode(response.body)['token'];
      // await const FlutterSecureStorage().write(key: 'auth_token', value: appToken);

      // 4. Navigasi ke Onboarding
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    } catch (error) {
      // Handle error (tampilkan snackbar, dll)
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Anda bisa pakai Icon atau Logo aplikasi di sini
              const Icon(Icons.cloud_circle_outlined, size: 120),
              const SizedBox(height: 20),
              const Text(
                'Selamat Datang di TitikKondisi',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Masuk untuk menyimpan preferensi dan mendapatkan pengalaman yang dipersonalisasi.',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => _signInWithGoogle(context),
                icon: const Icon(Icons.login), // Ganti dengan logo Google nanti
                label: const Text('Masuk dengan Google'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 24,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
