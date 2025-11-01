import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import '../services/location_service.dart';
import './setting_provider.dart';
class LocationProvider with ChangeNotifier {
  String? _currentLocationName;
  Position? _currentPosition;
  bool _isLoading = true;

  String? get currentLocationName => _currentLocationName;
  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;

  final LocationService _locationService = LocationService();
  SettingsProvider _settingsProvider; 

  LocationProvider(this._settingsProvider);

  Future<void> initialize() async {
    await _handleLocationBasedOnSettings();
  }

  void updateSettings(SettingsProvider newSettings) {
    final bool wasAutoLocation = _settingsProvider.autoLocation;
    _settingsProvider = newSettings;

    // Jika pengguna BARU SAJA menyalakan auto-location
    if (newSettings.autoLocation && !wasAutoLocation) {
      fetchInitialLocation();
    }
    // Jika pengguna BARU SAJA mematikan auto-location
    else if (!newSettings.autoLocation && wasAutoLocation) {
      _clearLocation();
    }
  }

  void _clearLocation() {
    _isLoading = false;
    _currentLocationName = "Lokasi otomatis nonaktif";
    _currentPosition = null;
    notifyListeners();
  }

  // 7. Buat method ini untuk logika utama
  Future<void> _handleLocationBasedOnSettings() async {
    if (_settingsProvider.autoLocation) {
      await fetchInitialLocation();
    } else {
      _clearLocation();
    }
  }

  Future<void> _saveLastKnownLocation(Position position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('last_lat', position.latitude);
    await prefs.setDouble('last_lon', position.longitude);
    print(
      'Lokasi disimpan ke SharedPreferences: ${position.latitude}, ${position.longitude}',
    );
  }

  Future<void> fetchInitialLocation() async {

    if (!_settingsProvider.autoLocation) {
      _clearLocation();
      return;
    }
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

  Future<void> setManualLocation(String locationName, Position? position) async {
    
    if (position != null) {
      _isLoading = false; 
      _currentLocationName = locationName;
      _currentPosition = position;
      await _saveLastKnownLocation(position);
      notifyListeners();
    } 

    else {
      _isLoading = true;
      notifyListeners(); 

      final Position? newPosition = 
          await _locationService.getCoordinatesFromAddress(locationName);

      if (newPosition != null) {
        // success  
        _currentPosition = newPosition;
        

        _currentLocationName = await _locationService.getAddressFromCoordinates(
          newPosition.latitude,
          newPosition.longitude,
        );
        
        // Saved into SharedPreferences
        await _saveLastKnownLocation(newPosition);
      } else {
        // Failed
        _currentLocationName = "Lokasi '$locationName' tidak ditemukan";
        _currentPosition = null;
      }
      
      _isLoading = false;
      notifyListeners(); 
    }
  }
}