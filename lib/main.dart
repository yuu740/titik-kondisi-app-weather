import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:titik_kondisi/provider/setting_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import './provider/subs_provider.dart';
import './screens/splash_screen.dart';
import './provider/theme_provider.dart';
import './provider/location_provider.dart';
import './themes/themes.dart';

import './services/fake_auth_service.dart';
import './services/fake_api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await initializeDateFormatting('id_ID', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()), // Tambahkan ini

        // Gunakan ChangeNotifierProvider untuk FakeAuthService agar UI bisa listen perubahannya
        ChangeNotifierProvider(create: (_) => FakeAuthService()), 
        Provider(create: (_) => FakeApiService()), // ApiService tidak perlu notify UI

        ChangeNotifierProxyProvider<FakeAuthService, SettingsProvider>(
          create: (context) => SettingsProvider(
            context.read<FakeAuthService>(),
            context.read<FakeApiService>(),
          ),
          update: (context, auth, previousSettings) => SettingsProvider(
            auth,
            context.read<FakeApiService>(),
          ),
        ),
      ],
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
      home: const SplashScreen(),
    );
  }
}
