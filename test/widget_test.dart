import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titik_kondisi/main.dart';
import 'package:titik_kondisi/provider/theme_provider.dart';
import 'package:titik_kondisi/screens/onboarding_screen.dart';
import 'package:titik_kondisi/screens/splash_screen.dart';
import 'package:titik_kondisi/screens/welcome_screen.dart';
import 'package:titik_kondisi/screens/main_screen.dart';
import 'package:titik_kondisi/screens/preference_page2.dart';

void main() {
  // Helper function untuk membungkus widget dengan provider yang dibutuhkan
  Widget createTestApp(Widget child) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MaterialApp(home: child),
    );
  }

  group('App Startup and Onboarding Flow', () {
    testWidgets('Shows SplashScreen then OnboardingScreen on first run', (
      WidgetTester tester,
    ) async {
      // FIX: Menggunakan cara modern untuk mock SharedPreferences
      SharedPreferences.setMockInitialValues({'isFirstRun': true});

      // FIX: Bangun aplikasi dari root (MyApp) tanpa parameter
      await tester.pumpWidget(const MyApp());

      // Awalnya, SplashScreen akan muncul
      expect(find.byType(SplashScreen), findsOneWidget);

      // Tunggu SplashScreen selesai dan navigasi
      await tester.pumpAndSettle();

      // Verifikasi bahwa OnboardingScreen muncul setelah SplashScreen
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text('Pengaturan Awal (1/2)'), findsOneWidget);
    });

    testWidgets('Shows SplashScreen then MainScreen on subsequent runs', (
      WidgetTester tester,
    ) async {
      // Simulasi pengguna yang sudah pernah membuka aplikasi
      SharedPreferences.setMockInitialValues({'isFirstRun': false});

      await tester.pumpWidget(const MyApp());

      // SplashScreen muncul
      expect(find.byType(SplashScreen), findsOneWidget);
      await tester.pumpAndSettle();

      // Verifikasi langsung ke MainScreen
      expect(find.byType(MainScreen), findsOneWidget);
    });

    testWidgets('Full onboarding navigation flow works correctly', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({'isFirstRun': true});
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(); // Selesaikan SplashScreen

      // 1. Berada di PreferencePage1
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text('Pengaturan Awal (1/2)'), findsOneWidget);

      // 2. Navigasi ke PreferencePage2
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.byType(PreferencePage2), findsOneWidget);

      // 3. Navigasi ke WelcomePage
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();
      expect(find.byType(WelcomeScreen), findsOneWidget);

      // 4. Tunggu animasi WelcomePage selesai dan navigasi ke MainScreen
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.byType(MainScreen), findsOneWidget);
    });
  });

  group('Theme Selection', () {
    testWidgets('WelcomePage shows light theme elements correctly', (
      WidgetTester tester,
    ) async {
      // Bangun langsung WelcomePage untuk test spesifik ini
      await tester.pumpWidget(createTestApp(const WelcomeScreen()));
      await tester.pump(); // Jalankan frame pertama

      // Verifikasi ikon dan warna gradien untuk light mode
      expect(find.byIcon(Icons.wb_sunny), findsOneWidget);

      // FIX: Mencari Container, bukan AnimatedContainer
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;

      expect(gradient.colors.contains(const Color(0xFF81D4FA)), isTrue);
    });

    testWidgets('WelcomePage shows dark theme elements correctly', (
      WidgetTester tester,
    ) async {
      // Buat provider tema khusus untuk test dark mode
      final themeProvider = ThemeProvider()..toggleTheme(true);

      // Bangun WelcomePage dengan provider dark mode
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: themeProvider,
          child: const MaterialApp(home: WelcomeScreen()),
        ),
      );
      await tester.pump();

      // Verifikasi ikon dan warna gradien untuk dark mode
      expect(find.byIcon(Icons.nights_stay), findsOneWidget);

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;

      expect(gradient.colors.contains(const Color(0xFF2C1C4F)), isTrue);
    });
  });
}
