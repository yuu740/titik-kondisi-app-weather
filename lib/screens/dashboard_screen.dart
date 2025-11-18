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
        title: const Text('Select Manual Location'), // EN
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter city name'), // EN
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'), // EN
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context, controller.text);
              }
            },
            child: const Text('Save'), // EN
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
    final weatherProvider = Provider.of<WeatherProvider>(context);
    
    if (!settingsProvider.autoLocation && locationProvider.currentPosition == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Dashboard"),
          elevation: 0,
          backgroundColor: Colors.transparent,
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
                  'Automatic location disabled.', // EN
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enable in settings or select location manually.', // EN
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _showSearchDialog(context),
                  child: const Text('Select Manual Location'), // EN
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                  child: const Text('Open Settings'), // EN
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (weatherProvider.isLoading && weatherProvider.weatherData == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text("Dashboard"), elevation: 0, backgroundColor: Colors.transparent),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Tampilkan error jika ada
    if (weatherProvider.error != null && weatherProvider.weatherData == null) {
      final errorString = weatherProvider.error.toString();
      bool isOfflineError = errorString.contains('SocketException') ||
          errorString.contains('Failed host lookup');
        
      if (isOfflineError) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text("Dashboard"),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: _buildOfflineErrorWidget(context),
        );
      } else {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text("Dashboard"),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Error Found: $errorString',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }
    }

    if (weatherProvider.weatherData == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text("Dashboard"), elevation: 0),
        body: const Center(child: Text('Weather data unavailable.')), // EN
      );
    }

    // --- DATA READY ---
    final apiData = weatherProvider.weatherData!;
    final weather = apiData.weather; 
    final rainData = weatherProvider.rainData;

    // Format tanggal ke Bahasa Inggris (en_US)
    final formattedDate = DateFormat(
      'EEEE, dd MMMM yyyy - HH:mm',
      'en_US', 
    ).format(DateTime.now());

    double temp = weather.temperature;
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
                        _buildHeader(theme, locationProvider, apiData),
                        const SizedBox(height: 16),
                        _buildWeatherCard(
                          theme,
                          formattedDate,
                          temp,
                          unit,
                          weather,
                        ),
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
                        _buildWeatherDetailsGrid(context, weather),
                        const SizedBox(height: 24),
                        Text(
                          'Rain Forecast (6h)', // EN
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        _buildRainForecast(context, rainData),
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
                  _buildHeader(theme, locationProvider, apiData),
                  const SizedBox(height: 16),
                  _buildWeatherCard(theme, formattedDate, temp, unit, weather),
                  const SizedBox(height: 24),
                  _buildWeatherDetailsGrid(context, weather),
                  const SizedBox(height: 24),
                  Text(
                    'Rain Forecast (6h)', // EN
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _buildRainForecast(context, rainData),
                ],
              ),
            );
          }
        },
      ),
    );
  }

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
              'Connection Failed', // EN
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Failed to load data. Please check your internet connection.', // EN
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Provider.of<WeatherProvider>(context, listen: false)
                    .fetchWeatherData();
              },
              child: const Text('Try Again'), // EN
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    ThemeData theme,
    LocationProvider locationProvider,
    ApiResponseData apiData,
  ) {
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final Color locationColor = isDarkMode ? Colors.white70 : Colors.black87;

    return AnimatedFadeSlide(
      delay: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rekomendasi Hiking (biasanya dari API sudah bahasa Inggris jika API mendukung,
          // jika tidak, kita tampilkan apa adanya dari API)
          Text(
            apiData.indices.hikingRecommendation,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Icon(Icons.location_on, color: locationColor, size: 18),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: locationProvider.isLoading
                    ? Text(
                        "Loading location...", // EN
                        style: TextStyle(color: locationColor),
                      )
                    : Text(
                        locationProvider.currentLocationName ??
                            "Unknown Location", // EN
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: locationColor,
                        ),
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
    WeatherData weather,
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
                weather.precipitation > 0
                    ? "Rainy" // EN
                    : (weather.cloudCover > 50 ? "Cloudy" : "Clear"), // EN
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

  Widget _buildWeatherDetailsGrid(BuildContext context, WeatherData weather) {
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
            value: weather.aqi.toString(),
            color: Colors.green,
          ),
          _InfoCard(
            icon: Icons.wb_sunny_outlined,
            label: 'UV Index',
            value: weather.uvIndex.toStringAsFixed(1),
            color: Colors.orange,
          ),
          _InfoCard(
            icon: Icons.water_drop_outlined,
            label: 'Precipitation', // EN
            value: '${weather.precipitation} mm',
            color: Colors.lightBlue,
          ),
          _InfoCard(
            icon: Icons.cloud_outlined,
            label: 'Cloud Cover', // EN
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

  Widget _buildRainForecast(BuildContext context, RainForecastData? rainData) {
    final theme = Theme.of(context);

    if (rainData == null || rainData.hourlyForecast.isEmpty) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: theme.cardColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
           border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
        ),
        child: const Center(
          child: Text(
            "Loading forecast...", // EN
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return AnimatedFadeSlide(
      delay: 500,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: theme.cardColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (Text Prediksi)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Icon(
                    Icons.info_outline_rounded, 
                    size: 18, 
                    color: theme.primaryColor
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    rainData.prediction, // API Prediction Text
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Chart
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: rainData.hourlyForecast.length,
                separatorBuilder: (context, index) => const SizedBox(width: 24),
                itemBuilder: (context, index) {
                  final item = rainData.hourlyForecast[index];
                  
                  // Panggil helper shortLabel dari model ('1 jam lagi' -> '1h')
                  // Pastikan model sudah diupdate
                  final durationLabel = item.shortLabel; 

                  // Helper probabilitas
                  final probabilityValue = item.probabilityValue;

                  final barColor = probabilityValue > 0.5 
                      ? theme.primaryColor 
                      : theme.primaryColor.withOpacity(0.4);

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        item.probability,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11, 
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.8)
                        ),
                      ),
                      const SizedBox(height: 6),
                      
                      Expanded(
                        child: Container(
                          width: 30,
                          alignment: Alignment.bottomCenter,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: probabilityValue),
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOutQuart,
                            builder: (context, value, _) {
                              return Container(
                                width: 30,
                                height: value == 0 ? 4 : (value * 70).clamp(4.0, 70.0),
                                decoration: BoxDecoration(
                                  color: barColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Label Waktu '1h', '2h'
                      Text(
                        durationLabel, 
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
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