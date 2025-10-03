import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:titik_kondisi/main.dart';
import 'package:titik_kondisi/provider/theme_provider.dart';
import 'package:titik_kondisi/screens/onboarding_screen.dart';
import 'package:titik_kondisi/screens/welcome_page.dart';
import 'package:titik_kondisi/screens/main_screen.dart';
import 'package:titik_kondisi/screens/preference_page2.dart'; // Ensure this path is correct
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart'; // For MethodChannel

void main() {
  // Setup mock SharedPreferences before each test
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    const MethodChannel(
      'plugins.flutter.io/shared_preferences',
    ).setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return <String, dynamic>{'isFirstRun': true}; // Simulasi first run
      }
      return null;
    });
  });

  // Clean up mock handler after each test
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('Theme switching and onboarding navigation test', (
    WidgetTester tester,
  ) async {
    // Build app with mock first run
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MyApp(
          isFirstRun: true,
        ), // Pass required isFirstRun parameter
      ),
    );

    // Verify that OnboardingScreen appears first
    expect(find.byType(OnboardingScreen), findsOneWidget);

    // Tap ChoiceChip "Dark" in PreferencePage1
    await tester.tap(find.widgetWithText(ChoiceChip, 'Dark'));
    await tester.pumpAndSettle();

    // Verify theme changes to dark mode
    final themeProvider = Provider.of<ThemeProvider>(
      tester.element(find.byType(OnboardingScreen)),
    );
    expect(themeProvider.themeMode, ThemeMode.dark);

    // Tap "Next" to navigate to PreferencePage2
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Verify PreferencePage2 appears
    expect(find.byType(PreferencePage2), findsOneWidget);

    // Tap "Get Started" to navigate to WelcomePage
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Verify WelcomePage appears with animation
    expect(find.byType(WelcomePage), findsOneWidget);

    // Wait 5 seconds for animation to complete and transition to MainScreen
    await tester.pumpAndSettle(const Duration(seconds: 6));
    expect(find.byType(MainScreen), findsOneWidget);
  });

  testWidgets('Theme affects WelcomePage animation', (
    WidgetTester tester,
  ) async {
    // Build app with mock first run
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MyApp(
          isFirstRun: true,
        ), // Pass required isFirstRun parameter
      ),
    );

    // Select Light mode
    await tester.tap(find.widgetWithText(ChoiceChip, 'Light'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Verify day gradient (light blue to white)
    final container = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    expect(container.decoration, isA<BoxDecoration>());
    final gradient =
        (container.decoration as BoxDecoration).gradient as LinearGradient;
    expect(gradient.colors, contains(Colors.blue[200]));

    // Switch to Dark mode and repeat
    await tester.pageBack(); // Navigate back to PreferencePage1
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Dark'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Verify night gradient (indigo to black)
    final darkContainer = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    final darkGradient =
        (darkContainer.decoration as BoxDecoration).gradient as LinearGradient;
    expect(darkGradient.colors, contains(Colors.indigo[900]));
  });
}

