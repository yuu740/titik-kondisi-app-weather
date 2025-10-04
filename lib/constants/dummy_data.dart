import 'dart:math';

class DummyData {
  // Daftar kondisi cuaca untuk dipilih secara acak
  static final List<String> _weatherConditions = [
    'Light rain',
    'Heavy rain',
    'Clear',
    'Cloudy',
  ];

  // Inisialisasi data cuaca dengan nilai acak
  static final String weatherCondition =
      _weatherConditions[Random().nextInt(_weatherConditions.length)];

  static const double temperature = 29.0;
  static const int aqi = 38;
  static const int uv = 0;
  static const int humidity = 72;
  static const String rainPrediction =
      'Hujan deras mungkin terjadi sore ini. Tetap waspada!';
  static const double observationScore = 9.1;
  static const int cloudCover = 5;
  static const String moonPhase = 'Baru';
  static const String lightPollution = 'Minimum';
  static const String bestTime = '21:45';

  static List<double> hourlyRain = [0.8, 0.6, 0.4, 0.2, 0.1, 0.05];
}
