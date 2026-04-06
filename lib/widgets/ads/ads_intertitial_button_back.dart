import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:try_out/widgets/ads/ads_constant.dart';

class InterstitialAdsBackButton {
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  static const String _lastAdShownKey = 'lastAdShownTimeInterstitial';
  static const int _adCooldownMinutes = 5;

  Function? onAdDismissed;

  InterstitialAdsBackButton({this.onAdDismissed});

  void loadAd() {
    if (_isAdLoaded || _interstitialAd != null) {
      return;
    }

    InterstitialAd.load(
      adUnitId: AdsConstants.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;

          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt(_lastAdShownKey, DateTime.now().millisecondsSinceEpoch);

              ad.dispose();
              _interstitialAd = null;
              _isAdLoaded = false;
              onAdDismissed?.call();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              _isAdLoaded = false;
              onAdDismissed?.call();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isAdLoaded = false;
        },
      ),
    );
  }

  Future<bool> showAd() async {
    final prefs = await SharedPreferences.getInstance();
    final lastAdShownTimeMillis = prefs.getInt(_lastAdShownKey) ?? 0;
    final currentTimeMillis = DateTime.now().millisecondsSinceEpoch;

    final differenceInMinutes = (currentTimeMillis - lastAdShownTimeMillis) / (1000 * 60);

    if (_isAdLoaded && _interstitialAd != null && differenceInMinutes >= _adCooldownMinutes) {
      _interstitialAd!.show();
      return true; // Ad will be shown
    } else {
      onAdDismissed?.call();
      return false; // Ad not shown
    }
  }

  /// Disposes the ad. Should be called when the helper is no longer needed.
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdLoaded = false;
  }
}