import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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

  Future<void> fetchInitialLocation() async {
    _isLoading = true;
    notifyListeners();

    _currentPosition = await _locationService.getCurrentLocation();
    if (_currentPosition != null) {
      _currentLocationName = await _locationService.getAddressFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
    } else {
      _currentLocationName = "Izin lokasi ditolak";
    }

    _isLoading = false;
    notifyListeners();
  }

  void setManualLocation(String locationName, Position? position) {
    _currentLocationName = locationName;
    _currentPosition = position; // Can be null for manual entry
    notifyListeners();
  }
}

