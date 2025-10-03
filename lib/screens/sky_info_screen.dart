import 'package:flutter/material.dart';
import '../constants/dummy_data.dart';

class SkyInfoScreen extends StatelessWidget {
  const SkyInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Info Langit',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    'Skor Observasi',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    DummyData.observationScore.toString(),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    'Menguntungkan awan, fase bulan, polusi cahaya.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SkyInfoItem(
                label: 'Tutupan Awan',
                value: '${DummyData.cloudCover}%',
              ),
              _SkyInfoItem(label: 'Fase Bulan', value: DummyData.moonPhase),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SkyInfoItem(
                label: 'Polusi Cahaya',
                value: DummyData.lightPollution,
              ),
              _SkyInfoItem(label: 'Best Time', value: DummyData.bestTime),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkyInfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _SkyInfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          value,
          style:
              Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ) ?? // Null-aware call
              const TextStyle(fontWeight: FontWeight.bold), // Fallback style
        ),
      ],
    );
  }
}

