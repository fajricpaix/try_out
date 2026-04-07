import 'package:flutter/foundation.dart';

class AdsConstants {
  // Official Google test IDs for Android while developing.
  static const String _testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  static const String _prodBannerAdUnitId =
      'ca-app-pub-2602479093941928/9052001071';
  static const String _prodInterstitialAdUnitId =
      'ca-app-pub-2602479093941928/6425837737';

  static String get bannerAdUnitId {
    return kReleaseMode ? _prodBannerAdUnitId : _testBannerAdUnitId;
  }

  static String get interstitialAdUnitId {
    return kReleaseMode ? _prodInterstitialAdUnitId : _testInterstitialAdUnitId;
  }
}