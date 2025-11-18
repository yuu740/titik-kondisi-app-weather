// screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_screen.dart';
import 'preference_page1.dart';
import 'preference_page2.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentPage = index),
        children: const [PreferencePage1(), PreferencePage2()],
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentPage > 0)
                TextButton(
                  onPressed: () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                  ),
                  child: const Text('Back'),
                ),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  if (_currentPage == 1) {
                    // --- PERUBAHAN UTAMA DI SINI ---
                    // Ini adalah "flag" yang Anda butuhkan.
                    // Setelah selesai, set flag menjadi false.
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('isFirstRunAfterLogin', false);

                    if (mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MainScreen()),
                      );
                    }
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  }
                },
                child: Text(_currentPage == 1 ? 'Let\'s start' : 'Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}