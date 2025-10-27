import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../models/weather_response.dart';

class WeatherService {
  final String _baseUrl = AppConfig.weatherApiUrl;

  Future<ApiResponseData> fetchWeatherData(double lat, double lon) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'lat': lat.toString(), 'lon': lon.toString()}),
      );

      if (response.statusCode == 200) {
        // --- TAMBAHKAN INI ---
        print('--- DEBUG: RAW JSON RESPONSE (WeatherService) ---');
        print(response.body);
        print('--------------------------------------------------');
        // Jika sukses, parse JSON menggunakan model kita
        return ApiResponseData.fromJson(jsonDecode(response.body));
      } else {
        // Jika gagal, lempar error
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }
}
