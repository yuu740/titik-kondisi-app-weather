class FakeApiService {
  Map<String, dynamic> _userSettings = {
    'isCelsius': true,
    'notifications': true,
    'autoLocation': true,
    'rainReminder': false,
    'astroReminder': false,
  };

  Future<Map<String, dynamic>> getSettings() async {
    await Future.delayed(const Duration(milliseconds: 500));
    print('SIMULATION: Fetching settings from fake server.'); // EN
    return _userSettings;
  }

  Future<void> updateSettings(Map<String, dynamic> newSettings) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _userSettings.addAll(newSettings);
    print('SIMULATION: Settings updated on fake server: $newSettings'); // EN
  }
}