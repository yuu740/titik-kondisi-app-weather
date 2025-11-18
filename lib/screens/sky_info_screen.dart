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

  Widget _buildOfflineErrorWidget(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_outlined, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Connection Failed',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Failed to load sky data. Ensure you are connected to the internet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Provider.of<WeatherProvider>(context, listen: false)
                    .fetchWeatherData();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);
    final weatherProvider = Provider.of<WeatherProvider>(context);

    if (!settingsProvider.autoLocation && locationProvider.currentPosition == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Night Sky Info'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off_outlined, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Automatic location disabled.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select manual location on the Dashboard to view data.',
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
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (weatherProvider.error != null && weatherProvider.weatherData == null) {
      final errorString = weatherProvider.error.toString();
      bool isOfflineError = errorString.contains('SocketException') ||
          errorString.contains('Failed host lookup');

      if (isOfflineError) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Night Sky Info'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: _buildOfflineErrorWidget(context),
        );
      } else {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Night Sky Info'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Center(
              child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text('Error: $errorString', textAlign: TextAlign.center),
          )),
        );
      }
    }
    if (weatherProvider.weatherData == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Night Sky Info')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final moonData = weatherProvider.weatherData!.moon;
    final weatherData = weatherProvider.weatherData!.weather;
    final sunData = weatherProvider.weatherData!.sun;
    final indicesData = weatherProvider.weatherData!.indices;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Night Sky Info'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // RESPONSIVE LOGIC PERBAIKAN:
          // Jika layar lebar (> 600), pakai 4 kolom. Jika kecil, 2 kolom.
          // Kita hitung aspect ratio agar kotak tidak terlalu gepeng jika teks panjang.
          int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
          
          // Semakin kecil layar, semakin tinggi (kecil rationya) kotak yang dibutuhkan
          // untuk menampung teks Fase Bulan yang mungkin panjang.
          double childAspectRatio = constraints.maxWidth > 600 ? 1.5 : 1.3;

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
                        label: 'Cloud Cover',
                        value: '${weatherData.cloudCover}%',
                      ),
                      _SkyInfoItem(
                        icon: Icons.nightlight_round,
                        label: 'Moon Phase',
                        // Menggunakan FittedBox di dalam item nanti agar teks panjang mengecil
                        value: moonData.phaseName, 
                      ),
                      _SkyInfoItem(
                        icon: Icons.lightbulb_outline,
                        label: 'Illumination',
                        value: '${(moonData.illumination * 100).toStringAsFixed(0)}%',
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
      elevation: 2, // Sedikit bayangan agar lebih pop-up
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: theme.primaryColor, size: 28),
            const Spacer(),
            Text(
              label, 
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)
              )
            ),
            const SizedBox(height: 4),
            // Menggunakan FittedBox agar teks panjang (Moon Phase) menyesuaikan ukuran
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}