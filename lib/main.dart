// main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './screens/splash_screen.dart'; // MODIFIED: Import splash screen
import './provider/theme_provider.dart';
import './themes/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Pengecekan isFirstRun dipindahkan ke SplashScreen
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
      debugShowCheckedModeBanner: false,
      // FIX: Home sekarang selalu SplashScreen
      home: const SplashScreen(),
    );
  }
}

