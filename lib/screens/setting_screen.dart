import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

// --- PROVIDERS ---
import '../provider/theme_provider.dart';
import '../provider/setting_provider.dart';
import '../provider/subs_provider.dart';
import '../provider/weather_provider.dart';
import '../provider/auth_provider.dart'; // Import AuthProvider

// --- SERVICES ---
import '../services/fake_api_service.dart';
import '../services/notification_service.dart';

// --- SCREENS ---
import 'welcome_screen.dart';
import './subs_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final subProvider = Provider.of<SubscriptionProvider>(context);
    final weatherProvider = Provider.of<WeatherProvider>(context);

    // --- LOGIKA SUBTITLE SUHU (C/F) ---
    String temperatureSubtitle;
    if (weatherProvider.weatherData != null) {
      double temp = weatherProvider.weatherData!.weather.temperature;
      String unit = "°C";
      if (!settingsProvider.isCelsius) {
        temp = (temp * 9 / 5) + 32;
        unit = "°F";
      }
      temperatureSubtitle = 'Current Temp: ${temp.toStringAsFixed(1)}$unit';
    } else {
      if (weatherProvider.error != null) {
        final errorString = weatherProvider.error.toString();
        bool isOfflineError = errorString.contains('SocketException') ||
            errorString.contains('Failed host lookup');

        if (isOfflineError) {
          temperatureSubtitle = 'Current Temp: N/A (Offline)';
        } else {
          temperatureSubtitle = 'Current Temp: N/A (Error)';
        }
      } else {
        temperatureSubtitle = 'Current Temp: N/A';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;

          // Gunakan GridView untuk layar lebar, ListView untuk HP
          return isWideScreen
              ? GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(16.0),
                  childAspectRatio: 3.5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: _buildSettingsList(
                    context,
                    themeProvider,
                    settingsProvider,
                    subProvider,
                    temperatureSubtitle,
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: _buildSettingsList(
                    context,
                    themeProvider,
                    settingsProvider,
                    subProvider,
                    temperatureSubtitle,
                  ),
                );
        },
      ),
    );
  }

  List<Widget> _buildSettingsList(
    BuildContext context,
    ThemeProvider themeProvider,
    SettingsProvider settingsProvider,
    SubscriptionProvider subProvider,
    String temperatureSubtitle,
  ) {
    return [
      // --- APPEARANCE ---
      _buildSectionTitle('APPEARANCE', context),
      _buildSwitchTile(
        context: context,
        icon: Icons.brightness_6_outlined,
        title: 'Dark Mode',
        value: themeProvider.themeMode == ThemeMode.dark,
        onChanged: (value) => themeProvider.toggleTheme(value),
      ),
      _buildSwitchTile(
        context: context,
        icon: Icons.notifications_active_outlined,
        title: 'Notifications',
        value: settingsProvider.notifications,
        onChanged: (value) => settingsProvider.setNotifications(value),
      ),

      // --- WEATHER ---
      _buildSectionTitle('WEATHER', context),
      _buildSwitchTile(
        context: context,
        icon: Icons.location_on_outlined,
        title: 'Auto Location',
        value: settingsProvider.autoLocation,
        onChanged: (value) => settingsProvider.setAutoLocation(value),
      ),
      _buildSwitchTile(
        context: context,
        icon: Icons.thermostat_outlined,
        title: 'Use Celsius',
        subtitle: temperatureSubtitle,
        value: settingsProvider.isCelsius,
        onChanged: (value) => settingsProvider.toggleTemperatureUnit(value),
      ),
      // Saya menghapus Rain/Astro reminder di sini agar sinkron dengan PreferencePage
      // dan tidak menyebabkan UI "kosong sebelah".

      // --- SUPPORT ---
      _buildSectionTitle('SUPPORT', context),
      Card(
        child: ListTile(
          leading: Icon(
            Icons.star,
            color: subProvider.isPro
                ? Colors.amber
                : Theme.of(context).primaryColor,
          ),
          title: const Text('Upgrade to Pro'),
          subtitle: Text(
            subProvider.isPro
                ? 'You are a Pro User'
                : 'Unlock advanced features',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
            );
          },
        ),
      ),

      // --- ACCOUNT ---
      _buildSectionTitle('ACCOUNT', context),
      Card(
        color: Colors.red[50],
        child: ListTile(
          leading: Icon(Icons.logout, color: Colors.red[700]),
          title: Text(
            'Logout',
            style: TextStyle(
              color: Colors.red[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () async {
            bool? confirmLogout = await showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Confirm Logout'),
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            );

            if (confirmLogout == true) {
              // Menggunakan AuthProvider untuk logout
              await context.read<AuthProvider>().logout();

              if (context.mounted) {
                // Kembali ke halaman awal (WelcomeScreen)
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                  (Route<dynamic> route) => false,
                );
              }
            }
          },
        ),
      ),

      // --- DEBUGGING ---
      _buildSectionTitle('DEBUGGING', context),

      Card(
        color: Colors.blue[50],
        child: ListTile(
          leading: Icon(Icons.visibility, color: Colors.blue[700]),
          title: Text(
            'Debug: Test Notification UI',
            style: TextStyle(color: Colors.blue[700]),
          ),
          subtitle: const Text('Trigger local notification (UI only)'),
          onTap: () async {
            final notificationService = NotificationService();
            await notificationService.initialize();

            await notificationService.showNotification(
              99,
              "Test Notification",
              "This is a sample notification for weather alerts.",
            );

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notification sent!')),
              );
            }
          },
        ),
      ),

      Card(
        color: Colors.orange[50],
        child: ListTile(
          leading: Icon(Icons.sync, color: Colors.orange[700]),
          title: Text(
            'Debug: Test Background Task',
            style: TextStyle(color: Colors.orange[700]),
          ),
          subtitle: const Text('Trigger WorkManager 1x'),
          onTap: () async {
            await Workmanager().registerOneOffTask(
              "1-oneoff-test",
              "fetchWeatherNotif",
              constraints: Constraints(networkType: NetworkType.connected),
            );

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Background task scheduled! Check console.'),
                ),
              );
            }
          },
        ),
      ),
    ];
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 8.0, left: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        secondary: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              )
            : null,
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}