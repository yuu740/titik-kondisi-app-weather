class RainForecastData {
  final String maxProbability;
  final num avgRainMm;
  final String prediction;
  final List<HourlyForecast> hourlyForecast;

  RainForecastData({
    required this.maxProbability,
    required this.avgRainMm,
    required this.prediction,
    required this.hourlyForecast,
  });

  factory RainForecastData.fromJson(Map<String, dynamic> json) {
    var list = json['hourly_forecast'] as List;
    List<HourlyForecast> forecastList =
        list.map((i) => HourlyForecast.fromJson(i)).toList();

    return RainForecastData(
      maxProbability: json['max_probability'] ?? "0%",
      avgRainMm: json['avg_rain_mm'] ?? 0,
      prediction: json['prediction'] ?? "No forecast data available.",
      hourlyForecast: forecastList,
    );
  }
}

class HourlyForecast {
  final String duration; // Example from API: "1 jam lagi" or "1 hour"
  final String probability;
  final num precipMm;

  HourlyForecast({
    required this.duration,
    required this.probability,
    required this.precipMm,
  });

  double get probabilityValue {
    String cleanString = probability.replaceAll('%', '');
    return (double.tryParse(cleanString) ?? 0) / 100;
  }

  // Helper untuk label singkat (mengambil angka saja + 'h')
  String get shortLabel {
    // Mengambil hanya angka dari string durasi, lalu tambah 'h'
    // Contoh: "1 jam lagi" -> "1h", "3 hours" -> "3h"
    return duration.replaceAll(RegExp(r'[^0-9]'), '') + 'h';
  }

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      duration: json['duration'] ?? "",
      probability: json['probability'] ?? "0%",
      precipMm: json['precip_mm'] ?? 0,
    );
  }
}