import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/theme_provider.dart';

class PreferencePage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pengaturan Awal',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text('Tema apa yang anda suka?'),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Light'),
                selected: themeProvider.themeMode == ThemeMode.light,
                onSelected: (_) => themeProvider.toggleTheme(false),
              ),
              const SizedBox(width: 10),
              ChoiceChip(
                label: const Text('Dark'),
                selected: themeProvider.themeMode == ThemeMode.dark,
                onSelected: (_) => themeProvider.toggleTheme(true),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Notifikasi'),
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
          const SizedBox(height: 20),
          const Text('Lokasi'),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Gunakan perangkat'),
                selected: true,
                onSelected: (_) {},
              ),
              const SizedBox(width: 10),
              ChoiceChip(
                label: const Text('Pilih manual'),
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
