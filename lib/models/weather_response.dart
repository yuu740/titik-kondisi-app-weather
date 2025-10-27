class ApiResponseData {
  final WeatherData weather;
  final SunData sun;
  final MoonData moon;
  final IndicesData indices;

  ApiResponseData({
    required this.weather,
    required this.sun,
    required this.moon,
    required this.indices,
  });

  factory ApiResponseData.fromJson(Map<String, dynamic> json) {
    return ApiResponseData(
      weather: WeatherData.fromJson(json['weather']),
      sun: SunData.fromJson(json['sun']),
      moon: MoonData.fromJson(json['moon']),
      indices: IndicesData.fromJson(json['indices']),
    );
  }
}

// Model untuk bagian "weather"
class WeatherData {
  final double temperature;
  final double precipitation;
  final int cloudCover;
  final double uvIndex;
  final int aqi;

  WeatherData({
    required this.temperature,
    required this.precipitation,
    required this.cloudCover,
    required this.uvIndex,
    required this.aqi,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['temperature'] as num).toDouble(),
      precipitation: (json['precipitation'] as num).toDouble(),
      cloudCover: (json['cloud_cover'] as num).toInt(),
      uvIndex: (json['uv_index'] as num).toDouble(),
      aqi: (json['aqi'] as num).toInt(),
    );
  }
}

// Model untuk bagian "sun"
class SunData {
  final String sunrise;
  final String sunset;
  final String goldenHour;

  SunData({
    required this.sunrise,
    required this.sunset,
    required this.goldenHour,
  });

  factory SunData.fromJson(Map<String, dynamic> json) {
    return SunData(
      sunrise: json['sunrise'],
      sunset: json['sunset'],
      goldenHour: json['golden_hour'],
    );
  }
}

// Model untuk bagian "moon"
class MoonData {
  final String phaseName;
  final double illumination;

  MoonData({required this.phaseName, required this.illumination});

  factory MoonData.fromJson(Map<String, dynamic> json) {
    return MoonData(
      phaseName: json['phase_name'],
      illumination: (json['illumination'] as num).toDouble(),
    );
  }
}

// Model untuk bagian "indices"
class IndicesData {
  final int hikingIndex;
  final String hikingRecommendation;

  IndicesData({required this.hikingIndex, required this.hikingRecommendation});

  factory IndicesData.fromJson(Map<String, dynamic> json) {
    return IndicesData(
      hikingIndex: (json['hiking_index'] as num).toInt(),
      hikingRecommendation: json['hiking_recommendation'],
    );
  }
}
