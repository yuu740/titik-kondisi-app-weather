import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/theme_provider.dart';
import 'preference_page1.dart';
import 'preference_page2.dart';
import 'welcome_page.dart';
import 'main_screen.dart';

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
        onPageChanged: (index) => setState(() => _currentPage = index),
        children: [
          PreferencePage1(),
          PreferencePage2(),
          WelcomePage(
            onStart: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MainScreen()),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
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
            TextButton(
              onPressed: () => _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease,
              ),
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
