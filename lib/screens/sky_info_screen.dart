import 'package:flutter/material.dart';
import '../constants/dummy_data.dart';
import '../widgets/radial_progress_widget.dart'; // NEW: Import widget baru
import 'dashboard_screen.dart'; // NEW: Import untuk widget animasi
import '../widgets/animated_fade_slide.dart';

class SkyInfoScreen extends StatelessWidget {
  const SkyInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // NEW: Tentukan jumlah kolom grid berdasarkan lebar layar
        int crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedFadeSlide(
                delay: 100,
                child: Text(
                  'Info Langit Malam',
                  style: theme.textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 20),

              AnimatedFadeSlide(
                delay: 200,
                child: Center(
                  child: RadialProgressIndicator(
                    score: DummyData.observationScore,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // NEW: GridView sekarang responsif
              AnimatedFadeSlide(
                delay: 300,
                child: GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _SkyInfoItem(
                      icon: Icons.cloud_outlined,
                      label: 'Tutupan Awan',
                      value: '${DummyData.cloudCover}%',
                    ),
                    _SkyInfoItem(
                      icon: Icons.nightlight_round,
                      label: 'Fase Bulan',
                      value: DummyData.moonPhase,
                    ),
                    _SkyInfoItem(
                      icon: Icons.lightbulb_outline,
                      label: 'Polusi Cahaya',
                      value: DummyData.lightPollution,
                    ),
                    _SkyInfoItem(
                      icon: Icons.access_time,
                      label: 'Waktu Terbaik',
                      value: DummyData.bestTime,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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

