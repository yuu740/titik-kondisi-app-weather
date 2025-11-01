import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:titik_kondisi/provider/setting_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:workmanager/workmanager.dart'; 

import './provider/subs_provider.dart';
import './screens/splash_screen.dart';
import './provider/theme_provider.dart';
import './provider/location_provider.dart';
import './themes/themes.dart';

import './services/fake_auth_service.dart';
import './services/fake_api_service.dart';
import './services/weather_service.dart';
import './provider/weather_provider.dart';
import './services/notification_service.dart'; 

@pragma('vm:entry-point') 
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    // --- DI SINILAH LOGIKA ANDA BERJALAN ---

    // 1. Inisialisasi yang Diperlukan (dotenv, dll.)
    // Kita perlu memuat ulang semua service/config di isolate baru ini
    await dotenv.load(fileName: ".env");

    // 2. Baca SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // Baca status 'isPro' dari kunci yang Anda gunakan di SubscriptionProvider
    final bool isPro = prefs.getBool('isPro') ?? false;

    // Baca lokasi terakhir dari kunci yang kita buat di LocationProvider
    final double? lat = prefs.getDouble('last_lat');
    final double? lon = prefs.getDouble('last_lon');

    final bool notificationsEnabled = prefs.getBool('notifications') ?? true;
    
    if (lat == null || lon == null) {
      print("Background Task: Gagal, tidak ada lokasi tersimpan.");
      return Future.value(false); 
    }

    if (!notificationsEnabled) {
      print("Background Task: Dibatalkan, notifikasi dimatikan dari pengaturan.");
      return Future.value(true); 
    }

    // 3. Inisialisasi Service Anda (TANPA Provider)
    // Kita buat instance baru karena ini isolate terpisah
    final weatherService = WeatherService();
    final notificationService = NotificationService();
    await notificationService.initialize(); // Inisialisasi notifikasi

    try {
      // 4. Panggil API
      print("Background Task: Fetching API data...");
      final apiData = await weatherService.fetchWeatherData(lat, lon);

      String notifTitle = "TitikKondisi";
      String notifBody;

      // 5. Logika Pro vs Free
      if (isPro) {
        // Pengguna Pro: Dapat "message opinter" (hikingRecommendation)
        notifBody =
            "${apiData.indices.hikingRecommendation} (Skor: ${apiData.indices.hikingIndex}/10)";
      } else {
        // Pengguna Free: Hanya dapat indeks
        notifBody = "Indeks Hiking hari ini: ${apiData.indices.hikingIndex}/10";
      }

      // 6. Tampilkan notifikasi
      print("Background Task: Menampilkan notifikasi: $notifBody");
      await notificationService.showNotification(0, notifTitle, notifBody);
      return Future.value(true); // Sukses
    } catch (e) {
      print("Background Task Error: $e");
      return Future.value(false); // Gagal
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await initializeDateFormatting('id_ID', null);
  await dotenv.load(fileName: ".env");
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true, // Set false saat rilis
  );

  // 6. DAFTARKAN TUGAS PERIODIK
  await Workmanager().registerPeriodicTask(
    "1", // ID unik untuk tugas Anda
    "fetchWeatherNotif", // Nama tugas
    frequency: const Duration(hours: 3), // Minimal 15 menit, 3 jam ideal
    constraints: Constraints(
      networkType: NetworkType.connected, // Hanya jalan jika ada internet
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(
          create: (_) => SubscriptionProvider(),
        ), // Tambahkan ini
        // Gunakan ChangeNotifierProvider untuk FakeAuthService agar UI bisa listen perubahannya
        ChangeNotifierProvider(create: (_) => FakeAuthService()),

        Provider(create: (_) => FakeApiService()),
        Provider(create: (_) => WeatherService()),
        ChangeNotifierProxyProvider<FakeAuthService, SettingsProvider>(
          create: (context) => SettingsProvider(
            context.read<FakeAuthService>(),
            context.read<FakeApiService>(),
          ),
          update: (context, auth, previousSettings) =>
              SettingsProvider(auth, context.read<FakeApiService>()),
        ),
        ChangeNotifierProxyProvider<LocationProvider, WeatherProvider>(
          create: (context) => WeatherProvider(context.read<WeatherService>()),
          // 'update' akan berjalan setiap kali LocationProvider memanggil notifyListeners()
          update: (context, location, weather) {
            // 'weather' adalah instance dari create, 'location' adalah data baru
            weather!.updateLocation(location); // Panggil method update kita
            return weather;
          },
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
