import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/dummy_data.dart';
import '../widgets/animated_fade_slide.dart';

// NEW: Ubah menjadi StatefulWidget untuk animasi
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // NEW: Gunakan LayoutBuilder untuk responsivitas
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isLandscape = constraints.maxWidth > 600;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // NEW: Tambahkan animasi pada setiap widget
              _AnimatedFadeSlide(
                delay: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DummyData.rainPrediction,
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DummyData.location,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // NEW: Logika untuk layout landscape vs portrait
              isLandscape
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildWeatherCard(theme)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildInfoChips(theme)),
                      ],
                    )
                  : Column(
                      children: [
                        _buildWeatherCard(theme),
                        const SizedBox(height: 20),
                        _buildInfoChips(theme),
                      ],
                    ),
              const SizedBox(height: 30),
              _AnimatedFadeSlide(
                delay: 400,
                child: Text(
                  'Prediksi Hujan 6 Jam ke Depan',
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 10),
              _AnimatedFadeSlide(
                delay: 500,
                child: Container(
                  height: 120,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: DummyData.hourlyRain.asMap().entries.map((entry) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: constraints.maxWidth / 12,
                            height: entry.value * 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.primaryColor.withOpacity(0.5),
                                  theme.primaryColor,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(6),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${entry.key + 1}h',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _AnimatedFadeSlide(
                delay: 600,
                child: Text(
                  'Peta Polusi Cahaya',
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 10),
              _AnimatedFadeSlide(
                delay: 700,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: const NetworkImage(
                          'https://www.lightpollutionmap.info/images/lp_map.jpg',
                        ),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.4),
                          BlendMode.darken,
                        ),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Light Pollution Map',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // NEW: Ekstrak widget untuk kerapian
  Widget _buildWeatherCard(ThemeData theme) {
    return _AnimatedFadeSlide(
      delay: 200,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              children: [
                Text(DummyData.date, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 10),
                Text(
                  '${DummyData.temperature}°C',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                Text(
                  DummyData.weatherCondition,
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChips(ThemeData theme) {
    return _AnimatedFadeSlide(
      delay: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _InfoChip(label: 'AQI', value: DummyData.aqi.toString()),
          const SizedBox(height: 12),
          _InfoChip(label: 'UV', value: DummyData.uv.toString()),
          const SizedBox(height: 12),
          _InfoChip(label: 'Humidity', value: '${DummyData.humidity}%'),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: theme.cardColor.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: theme.textTheme.bodyLarge),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// NEW: Widget helper untuk animasi
class _AnimatedFadeSlide extends StatefulWidget {
  final Widget child;
  final int delay;

  const _AnimatedFadeSlide({required this.child, this.delay = 0});

  @override
  State<_AnimatedFadeSlide> createState() => _AnimatedFadeSlideState();
}

class _AnimatedFadeSlideState extends State<_AnimatedFadeSlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(_controller);

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}
