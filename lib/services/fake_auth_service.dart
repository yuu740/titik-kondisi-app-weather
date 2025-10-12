import 'package:flutter/material.dart'; 
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class FakeAuthService with ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> login() async {
    print('SIMULASI: Pengguna berhasil login.');
    _isLoggedIn = true;
    notifyListeners(); 
  }

  Future<void> logout() async {
    print('SIMULASI: Pengguna berhasil logout.');
    await const FlutterSecureStorage().delete(key: 'auth_token');
    _isLoggedIn = false;
    notifyListeners();
  }
}