import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';

class AdManager {
  InterstitialAd? _interstitialAd;
  final String _adUnitId = 'ca-app-pub-3940256099942544/1033173712'; // ID Testing

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  // Modifikasi: Terima callback untuk dijalankan setelah iklan ditutup
  void showInterstitialAd({required VoidCallback onAdDismissed}) {
    if (_interstitialAd == null) {
      onAdDismissed(); // Jika iklan gagal dimuat, langsung jalankan callback
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        onAdDismissed(); // Jalankan callback di sini
        loadInterstitialAd(); // Muat lagi untuk nanti
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        onAdDismissed(); // Jalankan callback jika gagal tampil
        loadInterstitialAd();
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null;
  }
}