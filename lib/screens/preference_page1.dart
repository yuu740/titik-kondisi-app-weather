import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/theme_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PreferencePage1 extends StatefulWidget {
  const PreferencePage1({super.key});

  @override
  _PreferencePage1State createState() => _PreferencePage1State();
}

class _PreferencePage1State extends State<PreferencePage1> {
  // Menggunakan nullable boolean agar tidak ada yang terpilih di awal
  bool? _isNotificationEnabled;
  bool? _isLocationAutomatic;

  // Method untuk meminta izin notifikasi
  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    if (mounted) {
      setState(() {
        _isNotificationEnabled = status.isGranted;
      });
    }
  }

  // Method untuk meminta izin lokasi
  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (mounted) {
      setState(() {
        _isLocationAutomatic = status.isGranted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      // Tambahkan AppBar untuk estetika
      appBar: AppBar(
        title: const Text('Pengaturan Awal (1/2)'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
            const SizedBox(height: 40),

            // Pilihan Tema
            const Text(
              '1. Tema apa yang Anda suka?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Light'),
                    selected: themeProvider.themeMode == ThemeMode.light,
                    onSelected: (_) => themeProvider.toggleTheme(false),
                    labelStyle: TextStyle(
                      color: themeProvider.themeMode == ThemeMode.light
                          ? Theme.of(context).colorScheme.onPrimary
                          : null,
                    ),
                    selectedColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Dark'),
                    selected: themeProvider.themeMode == ThemeMode.dark,
                    onSelected: (_) => themeProvider.toggleTheme(true),
                    labelStyle: TextStyle(
                      color: themeProvider.themeMode == ThemeMode.dark
                          ? Theme.of(context).colorScheme.onPrimary
                          : null,
                    ),
                    selectedColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Pilihan Notifikasi
            const Text(
              '2. Izinkan pengingat cuaca?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Ya, tentu'),
                    selected: _isNotificationEnabled == true,
                    onSelected: (selected) {
                      if (selected) _requestNotificationPermission();
                    },
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Tidak'),
                    selected: _isNotificationEnabled == false,
                    onSelected: (selected) {
                      if (selected)
                        setState(() => _isNotificationEnabled = false);
                    },
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Pilihan Lokasi
            const Text(
              '3. Gunakan lokasi otomatis?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Gunakan perangkat'),
                    selected: _isLocationAutomatic == true,
                    onSelected: (selected) {
                      if (selected) _requestLocationPermission();
                    },
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Pilih manual'),
                    selected: _isLocationAutomatic == false,
                    onSelected: (selected) {
                      if (selected)
                        setState(() => _isLocationAutomatic = false);
                    },
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

