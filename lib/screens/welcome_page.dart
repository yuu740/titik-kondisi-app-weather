// screens/welcome_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../provider/theme_provider.dart';
import 'main_screen.dart';
import '../constants/app_colors.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    Future.delayed(const Duration(seconds: 4), () async {
      // Pengecekan 'if (mounted)' sudah benar untuk mengatasi warning
      // 'use_build_context_synchronously'. Ini memastikan context masih valid
      // setelah operasi async.
      if (mounted) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isFirstRun', false);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
                    const Color(0xFF2C1C4F),
                    AppColors.darkBackground,
                  ] // Ungu gelap ke hitam
                : [
                    const Color(0xFF81D4FA),
                    AppColors.lightBackground,
                  ], // Biru langit ke putih
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _animation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isDarkMode ? Icons.nights_stay : Icons.wb_sunny,
                    size: 100,
                    color: isDarkMode
                        ? AppColors.darkAccent
                        : Colors.yellow[700],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'TitikKondisi',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Prakiraan cuaca akurat dengan info langit malam terkini.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
