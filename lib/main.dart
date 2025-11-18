import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

// --- IMPORTS ---
import './provider/subs_provider.dart';
import './screens/splash_screen.dart';
import './provider/theme_provider.dart';
import './provider/location_provider.dart';
import './themes/themes.dart';

import 'services/auth_service.dart';
import './services/fake_api_service.dart';
import './services/weather_service.dart';
import './provider/weather_provider.dart';
import './provider/auth_provider.dart';
import './provider/setting_provider.dart';
import './services/notification_service.dart';

// --- MODELS IMPORTS ---
import './models/weather_response.dart';
import './models/rain_forecast_model.dart';

// --- HELPER FUNCTION: GENERATE SMART MESSAGE ---
String _generateSmartMessage({
  required WeatherData weather,
  required IndicesData indices,
  required RainForecastData rain,
  required bool isPro,
}) {
  // 1. CEK HUJAN (Prioritas Utama)
  if (rain.hourlyForecast.isNotEmpty) {
    var immediateForecasts = rain.hourlyForecast.take(2);
    
    for (var forecast in immediateForecasts) {
      int prob = int.tryParse(forecast.probability.replaceAll('%', '')) ?? 0;
      
      if (prob > 50) {
        if (isPro) {
          return "Warning: ${prob}% chance of rain ${forecast.duration}. Prepare your umbrella!";
        } else {
          return "Rain Alert: High chance of rain soon. Stay dry!";
        }
      }
    }
  }

  // 2. CEK HIKING (Prioritas Kedua)
  if (indices.hikingIndex >= 8) {
    if (isPro) {
      return "Perfect conditions! Hiking Score: ${indices.hikingIndex}/10. ${indices.hikingRecommendation}";
    } else {
      return "Great weather for outdoors! Hiking Score: ${indices.hikingIndex}/10.";
    }
  }

  // 3. INFO STANDAR (Prioritas Terakhir)
  if (isPro) {
    return "${indices.hikingRecommendation}. Temp: ${weather.temperature}°C, UV: ${weather.uvIndex}.";
  } else {
    return "Current Weather: ${weather.temperature}°C. Hiking Score: ${indices.hikingIndex}/10.";
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    // 1. Inisialisasi Environment
    await dotenv.load(fileName: ".env");
    final prefs = await SharedPreferences.getInstance();

    // 2. Ambil Data User
    final bool isPro = prefs.getBool('isPro') ?? false;
    final double? lat = prefs.getDouble('last_lat');
    final double? lon = prefs.getDouble('last_lon');
    final bool notificationsEnabled = prefs.getBool('notifications') ?? true;

    // 3. Validasi Awal
    if (lat == null || lon == null) {
      print("Background Task: Failed, no saved location.");
      return Future.value(false);
    }

    if (!notificationsEnabled) {
      print("Background Task: Cancelled, notifications disabled in settings.");
      return Future.value(true);
    }

    // 4. Inisialisasi Service
    final weatherService = WeatherService();
    final notificationService = NotificationService();
    await notificationService.initialize();

    try {
      print("Background Task: Fetching Data (Weather & Rain)...");

      // 5. Fetch Data Secara Paralel
      final results = await Future.wait([
        weatherService.fetchWeatherData(lat, lon), // Index 0
        weatherService.fetchRainForecast(lat, lon) // Index 1
      ]);

      final apiData = results[0] as ApiResponseData;
      final rainData = results[1] as RainForecastData;

      // 6. Generate Smart Message
      String notifTitle = "TitikKondisi • Sky Update";
      String notifBody = _generateSmartMessage(
        weather: apiData.weather,
        indices: apiData.indices,
        rain: rainData,
        isPro: isPro,
      );

      // 7. Tampilkan Notifikasi
      print("Background Task: Showing notification -> $notifBody");
      await notificationService.showNotification(0, notifTitle, notifBody);

      return Future.value(true); 

    } catch (e) {
      print("Background Task Error: $e");
      return Future.value(true); 
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
    isInDebugMode: true, // Ubah ke false saat rilis
  );

  // Daftarkan Tugas Periodik
  await Workmanager().registerPeriodicTask(
    "1_smart_weather_task",
    "fetchSmartWeather",
    frequency: const Duration(hours: 3),
    constraints: Constraints(
      networkType: NetworkType.connected,
      requiresBatteryNotLow: true,
    ),
    // --- PERBAIKAN DI SINI ---
    // Gunakan ExistingPeriodicWorkPolicy untuk registerPeriodicTask
    existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),        
        Provider(create: (_) => FakeApiService()),
        Provider(create: (_) => WeatherService()),

        ChangeNotifierProxyProvider<AuthProvider, SettingsProvider>(
          create: (context) => SettingsProvider(
            context.read<AuthProvider>(),
            context.read<FakeApiService>(),
          ),
          update: (context, auth, previousSettings) =>
              SettingsProvider(auth, context.read<FakeApiService>()),
        ),

        ChangeNotifierProxyProvider<SettingsProvider, LocationProvider>(
          create: (context) {
            final settings = context.read<SettingsProvider>();
            return LocationProvider(settings)..initialize();
          },
          update: (context, settings, previousLocation) {
            previousLocation!.updateSettings(settings);
            return previousLocation;
          },
        ),

        ChangeNotifierProxyProvider<LocationProvider, WeatherProvider>(
          create: (context) => WeatherProvider(context.read<WeatherService>()),
          update: (context, location, weather) {
            weather!.updateLocation(location);
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