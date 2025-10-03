import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './screens/onboarding_screen.dart';
import './screens/welcome_page.dart';
import './provider/theme_provider.dart';
import './themes/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isFirstRun = prefs.getBool('isFirstRun') ?? true;
  final savedTheme =
      prefs.getBool('isDarkMode') ?? false; // Ambil tema yang disimpan

  runApp(
    ChangeNotifierProvider(
      create: (_) =>
          ThemeProvider()
            ..setTheme(savedTheme), // Set tema berdasarkan penyimpanan
      child: MyApp(isFirstRun: isFirstRun),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isFirstRun;

  const MyApp({super.key, required this.isFirstRun});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'TitikKondisi',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      home: isFirstRun ? const OnboardingScreen() : const WelcomePage(),
    );
  }
}

