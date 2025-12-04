import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      final response = await _authService.login(email, password);
      
      // --- LOGIKA BARU: Simpan Status Pro dari API ---
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isPro', response.isPro); 
      // ----------------------------------------------

      const dummyToken = "session_aktif_pameran_2025"; 
      _token = dummyToken;
      _isLoggedIn = true;
      await _storage.write(key: 'session_token', value: dummyToken);
      
      print("Login Sukses. Pro Status: ${response.isPro}");
    } catch (e) {
      _isLoggedIn = false;
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
      
      // --- LOGIKA BARU: Simpan Status Pro dari API ---
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isPro', response.isPro);
      // ----------------------------------------------

      const dummyToken = "session_aktif_pameran_2025"; 
      _token = dummyToken;
      _isLoggedIn = true;
      await _storage.write(key: 'session_token', value: dummyToken);

      print("Register Sukses. Pro Status: ${response.isPro}");
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