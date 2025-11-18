import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../models/weather_response.dart';
import '../models/rain_forecast_model.dart';
import './location_provider.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService;
  LocationProvider? _locationProvider; // Akan di-update oleh ProxyProvider

  ApiResponseData? _weatherData;
  RainForecastData? _rainData;

  bool _isLoading = false;
  String? _error;

  ApiResponseData? get weatherData => _weatherData;
  RainForecastData? get rainData => _rainData; 

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Simpan koordinat terakhir untuk menghindari panggilan API berulang
  (double, double)? _lastFetchedCoords;

  WeatherProvider(this._weatherService);

  // Method ini akan dipanggil oleh ProxyProvider setiap kali LocationProvider berubah
  void updateLocation(LocationProvider newLocationProvider) {
    _locationProvider = newLocationProvider;

    if (_locationProvider?.currentPosition != null) {
      final newCoords = (
        _locationProvider!.currentPosition!.latitude, // <-- Diubah
        _locationProvider!.currentPosition!.longitude, // <-- Diubah
      );
      // --- AKHIR PERBAIKAN ---

      // Hanya ambil data jika:
      // 1. Koordinatnya baru (berbeda dari yang terakhir)
      // 2. Tidak sedang dalam proses loading
      if (newCoords != _lastFetchedCoords && !_isLoading) {
        fetchWeatherData();
      }
    } else if (_locationProvider?.isLoading == false && _weatherData == null) {
      // Jika lokasi gagal didapat, set error
      _error = "Tidak bisa mendapatkan lokasi. Cek izin lokasi Anda.";
      notifyListeners();
    }
  }

  Future<void> fetchWeatherData() async {
    if (_locationProvider?.currentPosition == null) {
      _error = "Lokasi tidak tersedia.";
      notifyListeners();
      return;
    }

    // Ambil lat/lon dari 'currentPosition'
    final lat = _locationProvider!.currentPosition!.latitude; // <-- Diubah
    final lon = _locationProvider!.currentPosition!.longitude; // <-- Diubah
    // --- AKHIR PERBAIKAN ---

    _isLoading = true;
    _error = null;
    _lastFetchedCoords = (
      lat,
      lon,
    ); // Tandai sebagai koordinat yang sedang diambil
    notifyListeners();

    try {

      final results = await Future.wait([
        _weatherService.fetchWeatherData(lat, lon),
        _weatherService.fetchRainForecast(lat, lon),
      ]);

      _weatherData = results[0] as ApiResponseData;
      _rainData = results[1] as RainForecastData;

    } catch (e) {
      _error = e.toString();
      _weatherData = null;
      _rainData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
