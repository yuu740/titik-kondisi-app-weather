import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  // Mendapatkan lokasi saat ini
  Future<Position?> getCurrentLocation() async {
    // 1. Cek status izin
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // 2. Jika ditolak, minta izin
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // Jika tetap ditolak, kembalikan null
        return null;
      }
    }

    // 3. Jika diizinkan, dapatkan lokasi
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Mengubah koordinat menjadi alamat yang bisa dibaca
  Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // Format: "Nama Kota, Provinsi"
        return "${place.subAdministrativeArea}, ${place.administrativeArea}";
      }
      return "Lokasi tidak ditemukan";
    } catch (e) {
      return "Gagal mendapatkan nama lokasi";
    }
  }
}

