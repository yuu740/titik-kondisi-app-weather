import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './screens/onboarding_screen.dart';
import './provider/theme_provider.dart';
import './themes/themes.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'TitikKondisi',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      home: const OnboardingScreen(),
    );
  }
}
