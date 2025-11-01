import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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

  // --- FUNGSI INI YANG DIMODIFIKASI ---
  // Mengubah koordinat menjadi alamat yang lebih spesifik
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

        // Membangun string alamat yang lebih detail
        // Prioritas: Nama Jalan > Kelurahan/Daerah > Kecamatan > Kota
        String address = "";

        if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
          address += "${place.thoroughfare}, ";
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          address += "${place.subLocality}, ";
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          address += "${place.locality}";
        } else if (place.subAdministrativeArea != null &&
            place.subAdministrativeArea!.isNotEmpty) {
          address += "${place.subAdministrativeArea}";
        }

        // Membersihkan koma di akhir jika ada
        if (address.endsWith(", ")) {
          address = address.substring(0, address.length - 2);
        }

        return address.isNotEmpty ? address : "Lokasi tidak diketahui";
      }
      return "Lokasi tidak ditemukan";
    } catch (e) {
      print("Error getting address: $e"); // Tambahkan print untuk debug
      return "Gagal mendapatkan nama lokasi";
    }
  }
  Future<Position?> getCoordinatesFromAddress(String address) async {
    try {
      // 1. Gunakan package geocoding untuk mencari alamat
      List<Location> locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        final location = locations.first;
        return Position(
          latitude: location.latitude,
          longitude: location.longitude,
          timestamp: DateTime.now(),
          accuracy: 0.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
      }
      return null;
    } catch (e) {
      print("Error getting coordinates from address: $e");
      return null;
    }
  }

}
