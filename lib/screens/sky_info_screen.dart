import 'package:flutter/material.dart';

import '../widgets/radial_progress_widget.dart';
import '../widgets/animated_fade_slide.dart';
import 'package:provider/provider.dart';
import '../provider/weather_provider.dart';

import '../provider/setting_provider.dart';
import '../provider/location_provider.dart';
import './setting_screen.dart';
class SkyInfoScreen extends StatelessWidget {
  const SkyInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);
    final weatherProvider = Provider.of<WeatherProvider>(context);
    if (!settingsProvider.autoLocation && locationProvider.currentPosition == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Info Langit Malam'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_off_outlined, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Lokasi otomatis nonaktif.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pilih lokasi manual di halaman Dashboard untuk melihat data.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                  child: const Text('Buka Pengaturan'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (weatherProvider.weatherData == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Info Langit Malam')),
        body: const Center(child: Text("Data belum dimuat.")),
      );
    }
    final moonData = weatherProvider.weatherData!.moon;
    final weatherData = weatherProvider.weatherData!.weather;
    final sunData = weatherProvider.weatherData!.sun;
    final indicesData = weatherProvider.weatherData!.indices;
    return Scaffold(
      backgroundColor: Colors.transparent, // Membuat scaffold transparan
      appBar: AppBar(
        title: const Text('Info Langit Malam'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
          double childAspectRatio = constraints.maxWidth < 600 ? 1.2 : 1.5;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedFadeSlide(
                  delay: 200,
                  child: Center(
                    child: RadialProgressIndicator(
                      score: indicesData.hikingIndex.toDouble(),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                AnimatedFadeSlide(
                  delay: 300,
                  child: GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: childAspectRatio,
                    children: [
                      _SkyInfoItem(
                        icon: Icons.cloud_outlined,
                        label: 'Tutupan Awan',
                        value: '${weatherData.cloudCover}%',
                      ),
                      _SkyInfoItem(
                        icon: Icons.nightlight_round,
                        label: 'Fase Bulan',
                        value: moonData.phaseName,
                      ),
                      _SkyInfoItem(
                        icon: Icons.lightbulb_outline,
                        label: 'Iluminasi Bulan',
                        value:
                            '${(moonData.illumination * 100).toStringAsFixed(0)}%',
                      ),
                      _SkyInfoItem(
                        icon: Icons.access_time,
                        label: 'Golden Hour',
                        value: sunData.goldenHour,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SkyInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SkyInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.cardColor.withOpacity(0.8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: theme.primaryColor, size: 28),
            const Spacer(),
            Text(label, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
