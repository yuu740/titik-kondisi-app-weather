import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/theme_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PreferencePage1 extends StatefulWidget {
  const PreferencePage1({super.key});

  @override
  State<PreferencePage1> createState() => _PreferencePage1State();
}

class _PreferencePage1State extends State<PreferencePage1> {
  bool? _isNotificationEnabled;
  bool? _isLocationAutomatic;

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    if (mounted) {
      setState(() => _isNotificationEnabled = status.isGranted);
    }
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (mounted) {
      setState(() => _isLocationAutomatic = status.isGranted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Awal (1/2)'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personalisasi Aplikasi',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Atur preferensi Anda untuk pengalaman terbaik.',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            _buildPreferenceCard(
              context: context,
              icon: Icons.color_lens_outlined,
              title: 'Tema Pilihan Anda',
              child: Wrap(
                // Menggunakan Wrap untuk responsivitas
                spacing: 12.0,
                runSpacing: 12.0,
                children: [
                  _buildChoiceChip(
                    context: context,
                    label: 'Light',
                    isSelected: themeProvider.themeMode == ThemeMode.light,
                    onSelected: (_) => themeProvider.toggleTheme(false),
                  ),
                  _buildChoiceChip(
                    context: context,
                    label: 'Dark',
                    isSelected: themeProvider.themeMode == ThemeMode.dark,
                    onSelected: (_) => themeProvider.toggleTheme(true),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildPreferenceCard(
              context: context,
              icon: Icons.notifications_active_outlined,
              title: 'Izinkan Pengingat Cuaca?',
              child: Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                children: [
                  _buildChoiceChip(
                    context: context,
                    label: 'Ya, tentu',
                    isSelected: _isNotificationEnabled == true,
                    onSelected: (selected) {
                      if (selected) _requestNotificationPermission();
                    },
                  ),
                  _buildChoiceChip(
                    context: context,
                    label: 'Tidak',
                    isSelected: _isNotificationEnabled == false,
                    onSelected: (selected) {
                      if (selected)
                        setState(() => _isNotificationEnabled = false);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildPreferenceCard(
              context: context,
              icon: Icons.location_on_outlined,
              title: 'Gunakan Lokasi Otomatis?',
              child: Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                children: [
                  _buildChoiceChip(
                    context: context,
                    label: 'Ya, Otomatis',
                    isSelected: _isLocationAutomatic == true,
                    onSelected: (selected) {
                      if (selected) _requestLocationPermission();
                    },
                  ),
                  _buildChoiceChip(
                    context: context,
                    label: 'Pilih Manual',
                    isSelected: _isLocationAutomatic == false,
                    onSelected: (selected) {
                      if (selected)
                        setState(() => _isLocationAutomatic = false);
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
