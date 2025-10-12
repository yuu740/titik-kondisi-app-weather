import 'package:flutter/material.dart';

class PreferencePage2 extends StatefulWidget {
  const PreferencePage2({super.key});

  @override
  State<PreferencePage2> createState() => _PreferencePage2State();
}

class _PreferencePage2State extends State<PreferencePage2> {
  bool _isCelsius = true;
  bool _isAstronomyReminder = false;
  bool _isRainReminder = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Lanjutan (2/2)'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading:
            false, // Tombol kembali di-handle oleh OnboardingScreen
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Preferensi Lainnya',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Pilih satuan dan pengingat yang Anda inginkan.',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            _buildPreferenceCard(
              context: context,
              icon: Icons.thermostat_outlined,
              title: 'Satuan Temperatur',
              child: Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                children: [
                  _buildChoiceChip(
                    context: context,
                    label: 'Celcius (°C)',
                    isSelected: _isCelsius,
                    onSelected: (selected) => setState(() => _isCelsius = true),
                  ),
                  _buildChoiceChip(
                    context: context,
                    label: 'Fahrenheit (°F)',
                    isSelected: !_isCelsius,
                    onSelected: (selected) =>
                        setState(() => _isCelsius = false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildPreferenceCard(
              context: context,
              icon: Icons.star_border_outlined,
              title: 'Ingin Pengingat Astronomi?',
              child: Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                children: [
                  _buildChoiceChip(
                    context: context,
                    label: 'Ya',
                    isSelected: _isAstronomyReminder,
                    onSelected: (selected) =>
                        setState(() => _isAstronomyReminder = true),
                  ),
                  _buildChoiceChip(
                    context: context,
                    label: 'Tidak',
                    isSelected: !_isAstronomyReminder,
                    onSelected: (selected) =>
                        setState(() => _isAstronomyReminder = false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildPreferenceCard(
              context: context,
              icon: Icons.water_drop_outlined,
              title: 'Ingin Pengingat Hujan?',
              child: Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                children: [
                  _buildChoiceChip(
                    context: context,
                    label: 'Ya',
                    isSelected: _isRainReminder,
                    onSelected: (selected) =>
                        setState(() => _isRainReminder = true),
                  ),
                  _buildChoiceChip(
                    context: context,
                    label: 'Tidak',
                    isSelected: !_isRainReminder,
                    onSelected: (selected) =>
                        setState(() => _isRainReminder = false),
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
