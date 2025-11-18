import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titik_kondisi/provider/auth_provider.dart';
import '../services/fake_api_service.dart';
import '../services/auth_service.dart';
class SettingsProvider with ChangeNotifier {
  bool _isCelsius = true;
  bool _notifications = true;
  bool _autoLocation = true;
  bool _rainReminder = true;
  bool _astroReminder = false;

  bool get isCelsius => _isCelsius;
  bool get notifications => _notifications;
  bool get autoLocation => _autoLocation;
  bool get rainReminder => _rainReminder;
  bool get astroReminder => _astroReminder;

  final AuthProvider _authService;
  final FakeApiService _apiService;

  SettingsProvider(this._authService, this._apiService) {
    _loadSettings();
  }
  Future<void> _loadSettings() async {
    if (_authService.isLoggedIn) {
      print("Status: Logged In. Memuat dari FAKE API.");
      final userSettings = await _apiService.getSettings();
      _isCelsius = userSettings['isCelsius'];
      _notifications = userSettings['notifications'];
      _autoLocation = userSettings['autoLocation'];
      _rainReminder = userSettings['rainReminder'];
      _astroReminder = userSettings['astroReminder'];
    } else {
      print("Status: Logged Out. Memuat dari SharedPreferences.");
      final prefs = await SharedPreferences.getInstance();
      _isCelsius = prefs.getBool('isCelsius') ?? true;
      _notifications = prefs.getBool('notifications') ?? true;
      _autoLocation = prefs.getBool('autoLocation') ?? true;
      _rainReminder = prefs.getBool('rainReminder') ?? true;
      _astroReminder = prefs.getBool('astroReminder') ?? false;
    }

    notifyListeners();
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    notifyListeners();
    if (_authService.isLoggedIn) {
      await _apiService.updateSettings({key: value});
    }
  }

  Future<void> reloadSettings() async {
    print("Memuat ulang pengaturan berdasarkan status auth...");
    await _loadSettings();
  }

  void toggleTemperatureUnit(bool value) {
    _isCelsius = value;
    _saveSetting('isCelsius', value);
  }

  void setNotifications(bool value) {
    _notifications = value;
    _saveSetting('notifications', value);
  }

  void setAutoLocation(bool value) {
    _autoLocation = value;
    _saveSetting('autoLocation', value);
  }

  void setRainReminder(bool value) {
    _rainReminder = value;
    _saveSetting('rainReminder', value);
  }

  void setAstroReminder(bool value) {
    _astroReminder = value;
    _saveSetting('astroReminder', value);
  }
}
