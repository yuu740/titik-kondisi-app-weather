import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SubscriptionStatus { free, pro }

class SubscriptionProvider with ChangeNotifier {
  SubscriptionStatus _status = SubscriptionStatus.free;
  SubscriptionStatus get status => _status;

  bool get isPro => _status == SubscriptionStatus.pro;

  SubscriptionProvider() {
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final prefs = await SharedPreferences.getInstance();

    final bool isProUser = prefs.getBool('isPro') ?? false;
    _status = isProUser ? SubscriptionStatus.pro : SubscriptionStatus.free;
    notifyListeners();
  }

  Future<void> _saveStatus(bool isProUser) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPro', isProUser);
  }

  void upgradeToPro() {
    _status = SubscriptionStatus.pro;
    _saveStatus(true); // Simpan status 'true' ke SharedPreferences
    notifyListeners();
    print("Status Pro Diaktifkan dan Disimpan.");
  }

  void downgradeToFree() {
    _status = SubscriptionStatus.free;
    _saveStatus(false); 
    notifyListeners();
    print("Status Pro Dinonaktifkan dan Disimpan.");
  }
}