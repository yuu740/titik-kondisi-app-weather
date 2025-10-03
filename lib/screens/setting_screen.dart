import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pengaturan',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text('Tampilan'),
          SwitchListTile(
            title: const Text('Mode gelap'),
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (value) => themeProvider.toggleTheme(value),
          ),
          SwitchListTile(
            title: const Text('Notifikasi'),
            value: true,
            onChanged: (_) {},
          ),
          const SizedBox(height: 20),
          const Text('Cuaca'),
          SwitchListTile(
            title: const Text('Lokasi Otomatis'),
            value: true,
            onChanged: (_) {},
          ),
          SwitchListTile(
            title: const Text('Satuan Temperatur °C'),
            value: true,
            onChanged: (_) {},
          ),
          SwitchListTile(
            title: const Text('Reminder Hujan'),
            value: true,
            onChanged: (_) {},
          ),
          const SizedBox(height: 20),
          const Text('Astronomi'),
          SwitchListTile(
            title: const Text('Pengingat Observasi'),
            value: false,
            onChanged: (_) {},
          ),
        ],
      ),
    );
  }
}

