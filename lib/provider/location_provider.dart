import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 1. IMPORT
import '../services/location_service.dart';

class LocationProvider with ChangeNotifier {
  String? _currentLocationName;
  Position? _currentPosition;
  bool _isLoading = true;

  String? get currentLocationName => _currentLocationName;
  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;

  final LocationService _locationService = LocationService();

  LocationProvider() {
    fetchInitialLocation();
  }

  // 2. TAMBAHKAN FUNGSI BARU
  Future<void> _saveLastKnownLocation(Position position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('last_lat', position.latitude);
    await prefs.setDouble('last_lon', position.longitude);
    print(
      'Lokasi disimpan ke SharedPreferences: ${position.latitude}, ${position.longitude}',
    );
  }

  Future<void> fetchInitialLocation() async {
    _isLoading = true;
    notifyListeners();

    _currentPosition = await _locationService.getCurrentLocation();
    if (_currentPosition != null) {
      _currentLocationName = await _locationService.getAddressFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      // 3. PANGGIL FUNGSI SIMPAN
      await _saveLastKnownLocation(_currentPosition!);
    } else {
      _currentLocationName = "Izin lokasi ditolak";
    }

    _isLoading = false;
    notifyListeners();
  }

  void setManualLocation(String locationName, Position? position) {
    _currentLocationName = locationName;
    _currentPosition = position;

    // 4. PANGGIL FUNGSI SIMPAN (jika ada data posisi)
    if (position != null) {
      _saveLastKnownLocation(position);
    }

    notifyListeners();
  }
}

