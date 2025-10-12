// services/fake_auth_service.dart

import 'package:flutter/material.dart'; // TAMBAHKAN INI

// TAMBAHKAN 'with ChangeNotifier'
class FakeAuthService with ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> login() async {
    print('SIMULASI: Pengguna berhasil login.');
    _isLoggedIn = true;
    notifyListeners(); // TAMBAHKAN INI untuk memberitahu UI
  }

  Future<void> logout() async {
    print('SIMULASI: Pengguna berhasil logout.');
    _isLoggedIn = false;
    notifyListeners(); // TAMBAHKAN INI untuk memberitahu UI
  }
}