import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/theme_provider.dart';
import '../provider/setting_provider.dart';
import '../constants/dummy_data.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    double temp = DummyData.temperature;
    String unit = "°C";
    if (!settingsProvider.isCelsius) {
      temp = (temp * 9 / 5) + 32;
      unit = "°F";
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;

          return isWideScreen
              ? GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(16.0),
                  childAspectRatio: 3.5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: _buildSettingsList(
                    context,
                    themeProvider,
                    settingsProvider,
                    temp,
                    unit,
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: _buildSettingsList(
                    context,
                    themeProvider,
                    settingsProvider,
                    temp,
                    unit,
                  ),
                );
        },
      ),
    );
  }

  List<Widget> _buildSettingsList(
    BuildContext context,
    ThemeProvider themeProvider,
    SettingsProvider settingsProvider,
    double temp,
    String unit,
  ) {
    return [
      _buildSectionTitle('Tampilan', context),
      _buildSwitchTile(
        context: context,
        icon: Icons.brightness_6_outlined,
        title: 'Mode Gelap',
        value: themeProvider.themeMode == ThemeMode.dark,
        onChanged: (value) => themeProvider.toggleTheme(value),
      ),
      _buildSwitchTile(
        context: context,
        icon: Icons.notifications_active_outlined,
        title: 'Notifikasi',
        value: settingsProvider.notifications,
        onChanged: (value) => settingsProvider.setNotifications(value),
      ),
      _buildSectionTitle('Cuaca', context),
      _buildSwitchTile(
        context: context,
        icon: Icons.location_on_outlined,
        title: 'Lokasi Otomatis',
        value: settingsProvider.autoLocation,
        onChanged: (value) => settingsProvider.setAutoLocation(value),
      ),
      _buildSwitchTile(
        context: context,
        icon: Icons.thermostat_outlined,
        title: 'Gunakan Celcius',
        subtitle: 'Suhu saat ini: ${temp.toStringAsFixed(1)}$unit',
        value: settingsProvider.isCelsius,
        onChanged: (value) => settingsProvider.toggleTemperatureUnit(value),
      ),
      _buildSwitchTile(
        context: context,
        icon: Icons.water_drop_outlined,
        title: 'Pengingat Hujan',
        value: settingsProvider.rainReminder,
        onChanged: (value) => settingsProvider.setRainReminder(value),
      ),
      _buildSectionTitle('Astronomi', context),
      _buildSwitchTile(
        context: context,
        icon: Icons.star_border_outlined,
        title: 'Pengingat Observasi',
        value: settingsProvider.astroReminder,
        onChanged: (value) => settingsProvider.setAstroReminder(value),
      ),
    ];
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 8.0, left: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        secondary: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              )
            : null,
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
