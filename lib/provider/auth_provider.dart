import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final _storage = const FlutterSecureStorage();

  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _token; // Ini nanti kita isi dummy token

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get token => _token;

  // Cek status login saat aplikasi baru dibuka
  Future<void> checkLoginStatus() async {
    // Kita cek apakah ada 'session_token' yang tersimpan
    final storedToken = await _storage.read(key: 'session_token');
    if (storedToken != null) {
      _token = storedToken;
      _isLoggedIn = true;
    } else {
      _isLoggedIn = false;
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Panggil API Asli
      final response = await _authService.login(email, password);
      
      print("API Response: ${response.message}");

      // 2. JIKA SUKSES (Tidak error):
      // Karena server tidak kirim token, kita buat "Dummy Token"
      // untuk menandakan di HP bahwa user ini sudah login.
      const dummyToken = "session_aktif_pameran_2025"; 

      _token = dummyToken;
      _isLoggedIn = true;

      // Simpan ke Secure Storage agar sesi bertahan walaupun app ditutup
      await _storage.write(key: 'session_token', value: dummyToken);
      
      print("Login Sukses. Sesi Lokal Dibuat.");
    } catch (e) {
      _isLoggedIn = false;
      print("Login Error: $e");
      rethrow; 
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password, String confirmPassword) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.register(email, password, confirmPassword);
      print("Register Response: ${response.message}");
      
      // Setelah register sukses, kita bisa langsung login-kan user (Auto Login)
      // Buat dummy token juga
      const dummyToken = "session_aktif_pameran_2025"; 
      _token = dummyToken;
      _isLoggedIn = true;
      await _storage.write(key: 'session_token', value: dummyToken);

      print("Register Sukses. Auto Login Aktif.");
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    // Hapus sesi lokal
    await _storage.delete(key: 'session_token');
    _token = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}