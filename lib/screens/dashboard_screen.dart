import 'package:flutter/material.dart';
import '../constants/dummy_data.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DummyData.rainPrediction,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 10),
          Text(DummyData.location),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(DummyData.date),
                  Text('${DummyData.temperature}°C'),
                  Text(DummyData.weatherCondition),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _InfoChip(
                label: 'AQI',
                value: DummyData.aqi.toString(),
                color: Colors.green,
              ),
              _InfoChip(
                label: 'UV',
                value: DummyData.uv.toString(),
                color: Colors.orange,
              ),
              _InfoChip(
                label: 'Humidity',
                value: '${DummyData.humidity}%',
                color: Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Prediksi Hujan 6 Jam ke Depan'),
          SizedBox(
            height: 100,
            child: Row(
              children: DummyData.hourlyRain
                  .map(
                    (rain) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        height: rain * 100, // Scale for bar height
                        color: Colors.blue,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Peta Polusi Cahaya'),
          Container(
            height: 200,
            color: Colors.grey[300], // Placeholder for map
            child: const Center(
              child: Text('Placeholder for Light Pollution Map'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Column(children: [Text(label), Text(value)]),
      backgroundColor: color.withOpacity(0.2),
    );
  }
}
