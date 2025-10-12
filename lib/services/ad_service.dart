import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  InterstitialAd? _interstitialAd;

  // Gunakan ID testing dari AdMob selama pengembangan
  final String _adUnitId = 'ca-app-pub-3940256099942544/1033173712';

  // Memuat iklan di awal agar siap saat dibutuhkan
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          print('InterstitialAd loaded.');
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  // Menampilkan iklan jika sudah dimuat
  void showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: Interstitial ad is not loaded yet.');
      return;
    }

    // Menangani event saat iklan ditampilkan
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadInterstitialAd(); // Muat iklan baru untuk sesi berikutnya
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        loadInterstitialAd();
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null;
  }
}