import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/setting_provider.dart';

class PreferencePage2 extends StatefulWidget {
  const PreferencePage2({super.key});

  @override
  State<PreferencePage2> createState() => _PreferencePage2State();
}

class _PreferencePage2State extends State<PreferencePage2> {

  bool _isCelsius = true;

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Settings (2/2)'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, 
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Final Touches',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Select your preferred temperature unit.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            
            _buildPreferenceCard(
              context: context,
              icon: Icons.thermostat_outlined,
              title: 'Temperature Unit',
              child: Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                children: [
                  _buildChoiceChip(
                    context: context,
                    label: 'Celsius (°C)',
                    isSelected: _isCelsius,
                    onSelected: (selected) {
                      setState(() => _isCelsius = true);
                      settingsProvider.toggleTemperatureUnit(true);
                    },
                  ),
                  _buildChoiceChip(
                    context: context,
                    label: 'Fahrenheit (°F)',
                    isSelected: !_isCelsius,
                    onSelected: (selected) {
                       setState(() => _isCelsius = false);
                       settingsProvider.toggleTemperatureUnit(false);
                    },
                  ),
                ],
              ),
            ),
            
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).colorScheme.onPrimary : null,
        fontWeight: FontWeight.bold,
      ),
      selectedColor: Theme.of(context).colorScheme.primary,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}