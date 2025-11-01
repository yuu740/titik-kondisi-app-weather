import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SubscriptionStatus { free, pro }

class SubscriptionProvider with ChangeNotifier {
  SubscriptionStatus _status = SubscriptionStatus.free;
  SubscriptionStatus get status => _status;

  bool get isPro => _status == SubscriptionStatus.pro;

  bool _isSubProcessing = false;
  bool get isSubProcessing => _isSubProcessing;

  bool _isDonationProcessing = false;
  bool get isDonationProcessing => _isDonationProcessing;


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

  Future<void> upgradeToPro() async {
    _isSubProcessing = true;
    notifyListeners();

    // Simulasi proses pembayaran (2 detik)
    await Future.delayed(const Duration(seconds: 2));

    _status = SubscriptionStatus.pro;
    _saveStatus(true);
    _isSubProcessing = false;
    notifyListeners();
    print("Status Pro Diaktifkan dan Disimpan.");
  }
  Future<void> downgradeToFree() async {
    _isSubProcessing = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _status = SubscriptionStatus.free;
    _saveStatus(false);
    _isSubProcessing = false;
    notifyListeners();
    print("Status Pro Dinonaktifkan dan Disimpan.");
  }

  Future<void> simulateDonation() async {
    _isDonationProcessing = true;
    notifyListeners();

    // Simulasi proses donasi (3 detik)
    await Future.delayed(const Duration(seconds: 3));

    _isDonationProcessing = false;
    notifyListeners();
  }
}