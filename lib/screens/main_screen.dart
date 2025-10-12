import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'sky_info_screen.dart';
import 'setting_screen.dart';
import '../widgets/weather_background.dart'; // Import background baru

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const SkyInfoScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gunakan Stack untuk menumpuk background dan konten
      body: Stack(
        children: [
          const WeatherBackground(), // Latar belakang animasi
          // Konten halaman (Dashboard, Sky Info, dll)
          _screens[_selectedIndex],
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        // Membuat BottomNavBar transparan agar background terlihat
        backgroundColor: Colors.transparent,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.nights_stay_outlined),
            activeIcon: Icon(Icons.nights_stay),
            label: 'Info Langit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
