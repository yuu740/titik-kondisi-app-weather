import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/payment_service.dart';
enum SubscriptionStatus { free, pro }

class SubscriptionProvider with ChangeNotifier {
  SubscriptionStatus _status = SubscriptionStatus.free;
  SubscriptionStatus get status => _status;
  bool get isPro => _status == SubscriptionStatus.pro;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  final PaymentService _paymentService = PaymentService();

  SubscriptionProvider() {
    refreshStatus(); 
  }

  Future<void> refreshStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isProUser = prefs.getBool('isPro') ?? false;
    _status = isProUser ? SubscriptionStatus.pro : SubscriptionStatus.free;
    notifyListeners();
  }

  Future<String?> processDonation(String amount) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final redirectUrl = await _paymentService.createDonation(amount);
      return redirectUrl; 
    } catch (e) {
      print("Donation Error: $e");
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<String?> processSubscription() async {
    _isProcessing = true;
    notifyListeners();

    try {
      final redirectUrl = await _paymentService.createSubscription();
      return redirectUrl;
    } catch (e) {
      print("Subscription Error: $e");
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
  
  Future<void> setProStatusManual(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPro', value);
    await refreshStatus();
  }
}