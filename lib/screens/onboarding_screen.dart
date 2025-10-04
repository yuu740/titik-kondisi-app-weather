// screens/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'preference_page1.dart';
import 'preference_page2.dart';
import 'welcome_page.dart';

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
        physics:
            const NeverScrollableScrollPhysics(), // Agar tidak bisa di-swipe
        onPageChanged: (index) => setState(() => _currentPage = index),

        children: [PreferencePage1(), PreferencePage2(), const WelcomePage()],
      ),
      bottomNavigationBar: _currentPage < 2
          ? BottomAppBar(
              elevation: 0,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                    const Spacer(), // Untuk mendorong tombol Next ke kanan
                    ElevatedButton(
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      },
                      child: Text(_currentPage == 1 ? 'Get Started' : 'Next'),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
