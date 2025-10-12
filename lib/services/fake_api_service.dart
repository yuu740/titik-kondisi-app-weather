class FakeApiService {
  // Ini adalah "database" palsu kita di memori
  Map<String, dynamic> _userSettings = {
    'isCelsius': true,
    'notifications': true,
    'autoLocation': true,
    'rainReminder': false,
    'astroReminder': false,
  };

  // Simulasi mengambil data dari server
  Future<Map<String, dynamic>> getSettings() async {
    // Menambahkan jeda palsu untuk meniru latensi jaringan
    await Future.delayed(const Duration(milliseconds: 500));
    print('SIMULASI: Mengambil pengaturan dari server palsu.');
    return _userSettings;
  }

  // Simulasi memperbarui data di server
  Future<void> updateSettings(Map<String, dynamic> newSettings) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _userSettings.addAll(newSettings);
    print('SIMULASI: Pengaturan diperbarui di server palsu: $newSettings');
  }
}
