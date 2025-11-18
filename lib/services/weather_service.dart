import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../models/weather_response.dart';
import '../models/rain_forecast_model.dart'; 
class WeatherService {
  final String _baseUrl = AppConfig.weatherEndpoint;

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

  Future<RainForecastData> fetchRainForecast(double lat, double lon) async {
    // Panggil fungsi URL dinamis
    final String url = AppConfig.getRainForecastUrl(lat, lon);
    
    try {
      print('--- DEBUG: GET Rain Data from $url ---');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print('--- DEBUG: Rain Data Success ---');
        return RainForecastData.fromJson(jsonDecode(response.body));
      } else {
        // Jika error, kembalikan data kosong/default agar tidak crash
        throw Exception('Rain API Error: ${response.statusCode}');
      }
    } catch (e) {
       throw Exception('Error fetching rain: $e');
    }
  }
}
