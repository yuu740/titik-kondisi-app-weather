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
          const Text(
            'Info Langit',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Text('Skor Observasi'),
                  Text(
                    DummyData.observationScore.toString(),
                    style: const TextStyle(fontSize: 48),
                  ),
                  const Text('Menguntungkan awan, fase bulan, polusi cahaya.'),
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
        Text(label),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
