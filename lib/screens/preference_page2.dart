import 'package:flutter/material.dart';

class PreferencePage2 extends StatefulWidget {
  @override
  _PreferencePage2State createState() => _PreferencePage2State();
}

class _PreferencePage2State extends State<PreferencePage2> {
  bool _isCelsius = true;
  bool _isAstronomyReminder = false;
  bool _isRainReminder = true;

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
                selected: _isCelsius,
                onSelected: (selected) {
                  setState(() {
                    _isCelsius = selected;
                  });
                },
              ),
              const SizedBox(width: 10),
              ChoiceChip(
                label: const Text('Fahrenheit (°F)'),
                selected: !_isCelsius,
                onSelected: (selected) {
                  setState(() {
                    _isCelsius = !selected;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Ingin pengingat astronomi?'),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Ya'),
                selected: _isAstronomyReminder,
                onSelected: (selected) {
                  setState(() {
                    _isAstronomyReminder = selected;
                  });
                },
              ),
              const SizedBox(width: 10),
              ChoiceChip(
                label: const Text('Tidak'),
                selected: !_isAstronomyReminder,
                onSelected: (selected) {
                  setState(() {
                    _isAstronomyReminder = !selected;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Ingin pengingat hujan?'),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Ya'),
                selected: _isRainReminder,
                onSelected: (selected) {
                  setState(() {
                    _isRainReminder = selected;
                  });
                },
              ),
              const SizedBox(width: 10),
              ChoiceChip(
                label: const Text('Tidak'),
                selected: !_isRainReminder,
                onSelected: (selected) {
                  setState(() {
                    _isRainReminder = !selected;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

