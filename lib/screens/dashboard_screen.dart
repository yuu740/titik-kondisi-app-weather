import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/dummy_data.dart';
import '../provider/location_provider.dart';
import '../provider/setting_provider.dart';
import '../widgets/animated_fade_slide.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  void _showSearchDialog(BuildContext context) async {
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );
    final TextEditingController controller = TextEditingController();

    String? result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Lokasi Manual'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Masukkan nama kota'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context, controller.text);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      locationProvider.setManualLocation(result, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locationProvider = Provider.of<LocationProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final formattedDate = DateFormat(
      'EEEE, dd MMMM yyyy - HH:mm',
      'id_ID',
    ).format(DateTime.now());

    double temp = DummyData.temperature;
    String unit = "°C";
    if (!settingsProvider.isCelsius) {
      temp = (temp * 9 / 5) + 32;
      unit = "°F";
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 650;

          if (isWideScreen) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(theme, locationProvider),
                        const SizedBox(height: 16),
                        _buildWeatherCard(theme, formattedDate, temp, unit),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWeatherDetailsGrid(context),
                        const SizedBox(height: 24),
                        Text(
                          'Prediksi Hujan 6 Jam ke Depan',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        _buildRainForecast(context),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(theme, locationProvider),
                  const SizedBox(height: 16),
                  _buildWeatherCard(theme, formattedDate, temp, unit),
                  const SizedBox(height: 24),
                  _buildWeatherDetailsGrid(context),
                  const SizedBox(height: 24),
                  Text(
                    'Prediksi Hujan 6 Jam ke Depan',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _buildRainForecast(context),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  // --- WIDGET INI YANG DIMODIFIKASI ---
  Widget _buildHeader(ThemeData theme, LocationProvider locationProvider) {
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final Color locationColor = isDarkMode ? Colors.white70 : Colors.black87;

    return AnimatedFadeSlide(
      delay: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(DummyData.rainPrediction, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Row(
            // Agar ikon dan tombol edit tetap di atas jika teks wrapping
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 2.0,
                ), // Menyesuaikan posisi ikon
                child: Icon(Icons.location_on, color: locationColor, size: 18),
              ),
              const SizedBox(width: 8),
              // Mengganti Expanded dengan Flexible agar teks bisa wrap
              Flexible(
                child: locationProvider.isLoading
                    ? Text(
                        "Memuat lokasi...",
                        style: TextStyle(color: locationColor),
                      )
                    : Text(
                        locationProvider.currentLocationName ??
                            "Lokasi tidak diketahui",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: locationColor,
                        ),
                        // Text akan otomatis wrap jika tidak muat
                      ),
              ),
              IconButton(
                icon: Icon(
                  Icons.edit_location_alt_outlined,
                  size: 20,
                  color: locationColor.withOpacity(0.7),
                ),
                onPressed: () => _showSearchDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard(
    ThemeData theme,
    String date,
    double temp,
    String unit,
  ) {
    return AnimatedFadeSlide(
      delay: 200,
      child: Card(
        elevation: 4,
        shadowColor: theme.primaryColor.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Text(
                date,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 16),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${temp.toStringAsFixed(1)}$unit',
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DummyData.weatherCondition,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDetailsGrid(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 250,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 2.5,
      ),
      itemCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final items = [
          _InfoCard(
            icon: Icons.air,
            label: 'AQI',
            value: DummyData.aqi.toString(),
            color: Colors.green,
          ),
          _InfoCard(
            icon: Icons.wb_sunny_outlined,
            label: 'UV Index',
            value: DummyData.uv.toString(),
            color: Colors.orange,
          ),
          _InfoCard(
            icon: Icons.water_drop_outlined,
            label: 'Humidity',
            value: '${DummyData.humidity}%',
            color: Colors.lightBlue,
          ),
          _InfoCard(
            icon: Icons.cloud_outlined,
            label: 'Cloud Cover',
            value: '${DummyData.cloudCover}%',
            color: Colors.grey,
          ),
        ];
        return AnimatedFadeSlide(
          delay: 300 + (index * 50),
          child: items[index],
        );
      },
    );
  }

  Widget _buildRainForecast(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedFadeSlide(
      delay: 500,
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: theme.cardColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
        ),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          itemCount: DummyData.hourlyRain.length,
          separatorBuilder: (context, index) => const SizedBox(width: 24),
          itemBuilder: (context, index) {
            final entry = DummyData.hourlyRain.asMap().entries.elementAt(index);
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${(entry.value * 100).toInt()}%',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Container(
                    width: 35,
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 35,
                      height: entry.value * 60,
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text('${entry.key + 1}h', style: theme.textTheme.bodySmall),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: color.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
