import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/rain_forecast_model.dart';
import '../models/weather_response.dart';

import '../provider/location_provider.dart';
import '../provider/setting_provider.dart';
import '../provider/weather_provider.dart';
import '../widgets/animated_fade_slide.dart';
import '../screens/setting_screen.dart';
import '../constants/app_colors.dart'; 

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  
  // --- DIALOG PENCARIAN LOKASI ---
  void _showSearchDialog(BuildContext context) async {
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );
    final TextEditingController controller = TextEditingController();

    String? result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Manual Location'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter city name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context, controller.text);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      locationProvider.setManualLocation(result, null);
    }
  }

  // --- HELPER COLORS ---
  Color _getStatusColor(double value, String type) {
    if (type == 'UV') {
      if (value <= 2) return AppColors.statusGood;
      if (value <= 5) return AppColors.statusWarning;
      return AppColors.statusDanger;
    } else if (type == 'AQI') {
      if (value <= 50) return AppColors.statusGood;
      if (value <= 100) return AppColors.statusWarning;
      return AppColors.statusDanger;
    }
    return Colors.grey;
  }

  // --- HELPER REKOMENDASI ---
  String _getRecommendation(WeatherData weather, RainForecastData? rain) {
    List<String> advice = [];
    
    bool willRain = rain?.hourlyForecast.any((h) => h.probabilityValue > 0.5) ?? false;
    if (weather.precipitation > 0 || willRain) {
      advice.add("☔ Bring an umbrella");
    }
    
    if (weather.uvIndex > 5) {
      advice.add("🧢 Wear a hat or sunglasses");
      advice.add("🧴 Use sunscreen");
    }
    
    if (weather.aqi > 100) {
      advice.add("😷 Wear a mask (High pollution)");
    } else if (weather.aqi > 50) {
       advice.add("⚠️ Sensitive groups should reduce outdoor activity");
    }

    if (advice.isEmpty) {
      return "✨ Great weather! Enjoy your day.";
    }
    
    return advice.join("\n");
  }

  // --- BUILD UTAMA ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locationProvider = Provider.of<LocationProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final weatherProvider = Provider.of<WeatherProvider>(context);
    
    // 1. Cek Manual Location Disabled
    if (!settingsProvider.autoLocation && locationProvider.currentPosition == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text("Dashboard"), elevation: 0, backgroundColor: Colors.transparent),
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
                  'Enable in settings or select location manually.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _showSearchDialog(context),
                  child: const Text('Select Manual Location'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 2. Loading State
    if (weatherProvider.isLoading && weatherProvider.weatherData == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text("Dashboard"), elevation: 0, backgroundColor: Colors.transparent),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 3. Error State
    if (weatherProvider.error != null && weatherProvider.weatherData == null) {
      final errorString = weatherProvider.error.toString();
      bool isOfflineError = errorString.contains('SocketException') || errorString.contains('Failed host lookup');
        
      if (isOfflineError) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(title: const Text("Dashboard"), elevation: 0, backgroundColor: Colors.transparent),
          body: _buildOfflineErrorWidget(context),
        );
      } else {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(title: const Text("Dashboard"), elevation: 0, backgroundColor: Colors.transparent),
          body: Center(child: Padding(padding: const EdgeInsets.all(20), child: Text('Error Found: $errorString', textAlign: TextAlign.center))),
        );
      }
    }

    // 4. Data Null Check
    if (weatherProvider.weatherData == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text("Dashboard"), elevation: 0),
        body: const Center(child: Text('Weather data unavailable.')),
      );
    }

    // --- DATA READY ---
    final apiData = weatherProvider.weatherData!;
    final weather = apiData.weather; 
    final rainData = weatherProvider.rainData;

    final formattedDate = DateFormat('EEEE, dd MMMM yyyy - HH:mm', 'en_US').format(DateTime.now());

    double temp = weather.temperature;
    String unit = "°C";
    if (!settingsProvider.isCelsius) {
      temp = (temp * 9 / 5) + 32;
      unit = "°F";
    }

    // Logika Kontras Warna (Text Putih jika Mendung/Malam)
    final bool isRaining = weather.precipitation > 0.1;
    final bool isCloudy = weather.cloudCover > 60;
    final bool isOvercast = isRaining || isCloudy;
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final Color headerTextColor = (isDarkMode || isOvercast) ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: headerTextColor),
        titleTextStyle: theme.textTheme.titleLarge?.copyWith(
          color: headerTextColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Breakpoint untuk layout Tablet/Desktop
          bool isWideScreen = constraints.maxWidth > 700;

          // List Widget Konten
          List<Widget> contentWidgets = [
            _buildHeader(theme, locationProvider, apiData, headerTextColor),
            const SizedBox(height: 16),
            _buildWeatherCard(theme, formattedDate, temp, unit, weather),
            const SizedBox(height: 16),
            AnimatedFadeSlide(delay: 250, child: _buildRecommendationCard(theme, weather, rainData)),
            const SizedBox(height: 24),
            _buildWeatherDetailsGrid(context, weather), // Grid Responsif Baru
            const SizedBox(height: 24),
            Text(
              'Rain Forecast (6h)',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: headerTextColor,
                shadows: [Shadow(offset: const Offset(0,1), blurRadius: 2, color: Colors.black.withOpacity(0.3))]
              ),
            ),
            const SizedBox(height: 12),
            _buildRainForecast(context, rainData),
            const SizedBox(height: 40),
          ];

          if (isWideScreen) {
            // Layout 2 Kolom untuk Layar Lebar
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: contentWidgets.sublist(0, 4)),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: contentWidgets.sublist(4)),
                  ),
                ),
              ],
            );
          } else {
            // Layout 1 Kolom untuk Mobile
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: contentWidgets,
              ),
            );
          }
        },
      ),
    );
  }

  // --- WIDGET PENDUKUNG ---

  Widget _buildOfflineErrorWidget(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_outlined, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Connection Failed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Failed to load data. Please check your internet connection.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Provider.of<WeatherProvider>(context, listen: false).fetchWeatherData(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, LocationProvider locationProvider, ApiResponseData apiData, Color textColor) {
    return AnimatedFadeSlide(
      delay: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            apiData.indices.hikingRecommendation,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(offset: const Offset(0, 1), blurRadius: 3, color: Colors.black.withOpacity(0.5))],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.location_on, color: textColor, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: locationProvider.isLoading
                    ? Text("Loading location...", style: TextStyle(color: textColor))
                    : Text(
                        locationProvider.currentLocationName ?? "Unknown Location",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                          shadows: [Shadow(offset: const Offset(0, 1), blurRadius: 2, color: Colors.black.withOpacity(0.5))],
                        ),
                      ),
              ),
              IconButton(
                icon: Icon(Icons.edit_location_alt_outlined, size: 20, color: textColor.withOpacity(0.9)),
                onPressed: () => _showSearchDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard(ThemeData theme, String date, double temp, String unit, WeatherData weather) {
    return AnimatedFadeSlide(
      delay: 200,
      child: Card(
        elevation: 6,
        shadowColor: theme.primaryColor.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Text(date, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${temp.toStringAsFixed(1)}$unit',
                  style: theme.textTheme.displayMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                weather.precipitation > 0 ? "Rainy" : (weather.cloudCover > 50 ? "Cloudy" : "Clear"),
                style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(ThemeData theme, WeatherData weather, RainForecastData? rain) {
    String advice = _getRecommendation(weather, rain);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
         color: theme.cardColor.withOpacity(0.9),
         borderRadius: BorderRadius.circular(16),
         border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundColor: theme.primaryColor.withOpacity(0.1), child: Icon(Icons.tips_and_updates, color: theme.primaryColor)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text("Daily Advice", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                 const SizedBox(height: 4),
                 Text(advice, style: theme.textTheme.bodyMedium?.copyWith(height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- GRID DETAIL RESPONSIF ---
  Widget _buildWeatherDetailsGrid(BuildContext context, WeatherData weather) {
    // Menggunakan LayoutBuilder agar kita tahu lebar container saat ini
    return LayoutBuilder(
      builder: (context, constraints) {
        // Logika Responsif:
        // Gunakan SliverGridDelegateWithMaxCrossAxisExtent.
        // Ini akan otomatis mengisi kolom sebanyak mungkin asalkan tiap item
        // lebarnya maksimal 200 pixel.
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200, // Lebar ideal per kartu
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.3, // Rasio Lebar:Tinggi (Agar teks muat)
          ),
          itemCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final items = [
              _InfoCard(
                title: "AQI",
                value: weather.aqi.toString(),
                icon: Icons.air,
                color: _getStatusColor(weather.aqi.toDouble(), 'AQI'),
                isProgress: true,
                maxValue: 200,
                currentValue: weather.aqi.toDouble(),
              ),
              _InfoCard(
                title: "UV Index",
                value: weather.uvIndex.toStringAsFixed(1),
                icon: Icons.wb_sunny_outlined,
                color: _getStatusColor(weather.uvIndex, 'UV'),
                isProgress: true,
                maxValue: 12,
                currentValue: weather.uvIndex,
              ),
              _InfoCard(
                icon: Icons.water_drop_outlined,
                title: 'Precipitation',
                value: '${weather.precipitation} mm',
                color: Colors.blueAccent,
              ),
              _InfoCard(
                icon: Icons.cloud_outlined,
                title: 'Cloud Cover',
                value: '${weather.cloudCover}%',
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
    );
  }

  Widget _buildRainForecast(BuildContext context, RainForecastData? rainData) {
    final theme = Theme.of(context);

    if (rainData == null || rainData.hourlyForecast.isEmpty) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: theme.cardColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
        ),
        child: const Center(child: Text("Loading forecast...", style: TextStyle(color: Colors.grey))),
      );
    }

    return AnimatedFadeSlide(
      delay: 500,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: theme.cardColor.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 18, color: theme.primaryColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    rainData.prediction,
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, height: 1.3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: rainData.hourlyForecast.length,
                separatorBuilder: (context, index) => const SizedBox(width: 24),
                itemBuilder: (context, index) {
                  final item = rainData.hourlyForecast[index];
                  final prob = item.probabilityValue;

                  // --- LOGIKA WARNA BAR (HIJAU, KUNING, MERAH) ---
                  Color barColor;
                  if (prob <= 0.1) {
                    barColor = AppColors.statusGood; // Hijau
                  } else if (prob <= 0.5) {
                    barColor = AppColors.statusWarning; // Kuning
                  } else {
                    barColor = AppColors.statusDanger; // Merah
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(item.probability, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.textTheme.bodyMedium?.color), textAlign: TextAlign.center),
                      const SizedBox(height: 6),
                      Container(
                        width: 16,
                        height: 80,
                        alignment: Alignment.bottomCenter,
                        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                        child: FractionallySizedBox(
                          heightFactor: prob.clamp(0.05, 1.0),
                          child: Container(decoration: BoxDecoration(color: barColor, borderRadius: BorderRadius.circular(10))),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(item.shortLabel, style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color), textAlign: TextAlign.center),
                    ],
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );         
  }
}

// Widget Info Card (Isi Rata Tengah)
class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isProgress;
  final double currentValue;
  final double maxValue;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isProgress = false,
    this.currentValue = 0,
    this.maxValue = 100,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("$title is currently $value"),
          duration: const Duration(milliseconds: 800),
          behavior: SnackBarBehavior.floating,
        ));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))]
        ),
        // Rata Tengah (Center)
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, 
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]), overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Gunakan FittedBox agar angka besar tidak overflow
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ),
            
            if (isProgress) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (currentValue / maxValue).clamp(0.0, 1.0),
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}