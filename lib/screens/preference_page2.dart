import 'package:flutter/material.dart';

class PreferencePage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Satuan temperatur'),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Celcius (°C)'),
                selected: true,
                onSelected: (_) {},
              ),
              const SizedBox(width: 10),
              ChoiceChip(
                label: const Text('Fahrenheit (°F)'),
                selected: false,
                onSelected: (_) {},
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Ingin pengingat astronomi?'),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Ya'),
                selected: false,
                onSelected: (_) {},
              ),
              const SizedBox(width: 10),
              ChoiceChip(
                label: const Text('Tidak'),
                selected: true,
                onSelected: (_) {},
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Ingin pengingat hujan?'),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Ya'),
                selected: true,
                onSelected: (_) {},
              ),
              const SizedBox(width: 10),
              ChoiceChip(
                label: const Text('Tidak'),
                selected: false,
                onSelected: (_) {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
