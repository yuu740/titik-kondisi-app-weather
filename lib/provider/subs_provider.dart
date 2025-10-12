// provider/subscription_provider.dart
import 'package:flutter/material.dart';

enum SubscriptionStatus { free, pro }

class SubscriptionProvider with ChangeNotifier {
  SubscriptionStatus _status = SubscriptionStatus.free;
  SubscriptionStatus get status => _status;

  bool get isPro => _status == SubscriptionStatus.pro;

  void upgradeToPro() {
    _status = SubscriptionStatus.pro;
    notifyListeners();
    // Di aplikasi nyata, di sini Anda akan memvalidasi pembelian
  }

  void downgradeToFree() {
    _status = SubscriptionStatus.free;
    notifyListeners();
  }
}