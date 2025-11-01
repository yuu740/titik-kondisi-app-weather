import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/theme_provider.dart';
import '../provider/setting_provider.dart';
import '../provider/subs_provider.dart';
import '../provider/weather_provider.dart'; 

import '../services/fake_api_service.dart';
import '../services/fake_auth_service.dart';

// 3. IMPORT UNTUK DEBUGGING
import 'package:workmanager/workmanager.dart';
import '../services/notification_service.dart';

import 'welcome_screen.dart';
import './subs_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final subProvider = Provider.of<SubscriptionProvider>(context);

    // 4. GUNAKAN WeatherProvider untuk suhu
    final weatherProvider = Provider.of<WeatherProvider>(context);

    String temperatureSubtitle;

    if (weatherProvider.weatherData != null) {
      double temp = weatherProvider.weatherData!.weather.temperature;
      String unit = "°C";
      if (!settingsProvider.isCelsius) {
        temp = (temp * 9 / 5) + 32;
        unit = "°F";
      }
      temperatureSubtitle = 'Suhu saat ini: ${temp.toStringAsFixed(1)}$unit';
    } else {
   
      if (weatherProvider.error != null) {
        final errorString = weatherProvider.error.toString();
        bool isOfflineError = errorString.contains('SocketException') ||
            errorString.contains('Failed host lookup');
        
        if (isOfflineError) {
          temperatureSubtitle = 'Suhu saat ini: N/A (Offline)';
        } else {
          temperatureSubtitle = 'Suhu saat ini: N/A (Error)';
        }
      } else {
        temperatureSubtitle = 'Suhu saat ini: N/A';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;

          return isWideScreen
              ? GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(16.0),
                  childAspectRatio: 3.5, // Sesuaikan rasio jika perlu
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: _buildSettingsList(
                    context,
                    themeProvider,
                    settingsProvider,
                    subProvider,

                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: _buildSettingsList(
                    context,
                    themeProvider,
                    settingsProvider,
                    subProvider,

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
  ) {
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    String temperatureSubtitle;

    if (weatherProvider.weatherData != null) {
       double tempVal = weatherProvider.weatherData!.weather.temperature;
       String unitVal = "°C";
       if (!settingsProvider.isCelsius) {
         tempVal = (tempVal * 9 / 5) + 32;
         unitVal = "°F";
       }
       temperatureSubtitle = 'Suhu saat ini: ${tempVal.toStringAsFixed(1)}$unitVal';
    } else {
       if (weatherProvider.error != null) {
         final errorString = weatherProvider.error.toString();
         bool isOfflineError = errorString.contains('SocketException') ||
             errorString.contains('Failed host lookup');
         temperatureSubtitle = isOfflineError ? 'Suhu saat ini: N/A (Offline)' : 'Suhu saat ini: N/A (Error)';
       } else {
         temperatureSubtitle = 'Suhu saat ini: N/A';
       }
    }
    return [
      _buildSectionTitle('Tampilan', context),
      _buildSwitchTile(
        context: context,
        icon: Icons.brightness_6_outlined,
        title: 'Mode Gelap',
        value: themeProvider.themeMode == ThemeMode.dark,
        onChanged: (value) => themeProvider.toggleTheme(value),
      ),
      _buildSwitchTile(
        context: context,
        icon: Icons.notifications_active_outlined,
        title: 'Notifikasi',
        value: settingsProvider.notifications,
        onChanged: (value) => settingsProvider.setNotifications(value),
      ),
      _buildSectionTitle('Cuaca', context),
      _buildSwitchTile(
        context: context,
        icon: Icons.location_on_outlined,
        title: 'Lokasi Otomatis',
        value: settingsProvider.autoLocation,
        onChanged: (value) => settingsProvider.setAutoLocation(value),
      ),
      _buildSwitchTile(
        context: context,
        icon: Icons.thermostat_outlined,
        title: 'Gunakan Celcius',
        subtitle: temperatureSubtitle,
        value: settingsProvider.isCelsius,
        onChanged: (value) => settingsProvider.toggleTemperatureUnit(value),
      ),
      _buildSwitchTile(
        context: context,
        icon: Icons.water_drop_outlined,
        title: 'Pengingat Hujan',
        value: settingsProvider.rainReminder,
        onChanged: (value) => settingsProvider.setRainReminder(value),
      ),
      _buildSectionTitle('Astronomi', context),
      _buildSwitchTile(
        context: context,
        icon: Icons.star_border_outlined,
        title: 'Pengingat Observasi',
        value: settingsProvider.astroReminder,
        onChanged: (value) => settingsProvider.setAstroReminder(value),
      ),
      _buildSectionTitle('Dukungan', context),
      Card(
        child: ListTile(
          leading: Icon(
            Icons.star,
            color: subProvider.isPro
                ? Colors.amber
                : Theme.of(context).primaryColor,
          ),
          title: const Text('Upgrade ke Pro'),
          subtitle: Text(
            subProvider.isPro
                ? 'Anda adalah pengguna Pro'
                : 'Buka semua fitur canggih',
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
      _buildSectionTitle('Akun', context),
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
                title: const Text('Konfirmasi Logout'),
                content: const Text('Apakah Anda yakin ingin keluar?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Batal'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            );

            // 6. PERBAIKAN LOGIKA: Hanya navigasi jika confirmLogout == true
            if (confirmLogout == true) {
              await context.read<FakeAuthService>().logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                (Route<dynamic> route) => false,
              );
            }
            // Baris navigasi yang ada di sini sebelumnya telah dihapus
          },
        ),
      ),

      // --- 7. TOMBOL DEBUG DITAMBAHKAN DI SINI ---
      _buildSectionTitle('Debugging', context),

      // Tombol 1: Tes Tampilan Notifikasi
      Card(
        color: Colors.blue[50],
        child: ListTile(
          leading: Icon(Icons.visibility, color: Colors.blue[700]),
          title: Text(
            'Debug: Tes Tampilan Notifikasi',
            style: TextStyle(color: Colors.blue[700]),
          ),
          subtitle: const Text('Memicu notifikasi lokal (hanya UI)'),
          onTap: () async {
            print("DEBUG: Memicu notifikasi lokal (UI Only)...");
            final notificationService = NotificationService();
            await notificationService.initialize();

            // Tes Versi Free
            await notificationService.showNotification(
              98, // ID unik untuk tes
              "Tes Notifikasi (Free)",
              "Indeks Hiking hari ini: 7/10",
            );

            // Jeda singkat
            await Future.delayed(const Duration(seconds: 2));

            // Tes Versi Pro
            await notificationService.showNotification(
              99, // ID unik untuk tes
              "Tes Notifikasi (Pro)",
              "Cukup baik, tapi perhatikan cuaca. (Skor: 7/10)",
            );

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tes notifikasi UI dikirim!')),
              );
            }
          },
        ),
      ),

      // Tombol 2: Tes Logika Latar Belakang
      Card(
        color: Colors.orange[50],
        child: ListTile(
          leading: Icon(Icons.sync, color: Colors.orange[700]),
          title: Text(
            'Debug: Tes Logika Latar Belakang',
            style: TextStyle(color: Colors.orange[700]),
          ),
          subtitle: const Text('Memicu WorkManager 1x (alur penuh)'),
          onTap: () async {
            print("DEBUG: Memicu tugas WorkManager satu-kali...");
            await Workmanager().registerOneOffTask(
              "1-oneoff-test", // ID Unik untuk tugas ini
              "fetchWeatherNotif", // Nama TUGAS YANG SAMA dengan di main.dart
              constraints: Constraints(networkType: NetworkType.connected),
            );

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Tugas latar belakang dijadwalkan! Cek konsol & notifikasi dalam ~30 detik.',
                  ),
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
