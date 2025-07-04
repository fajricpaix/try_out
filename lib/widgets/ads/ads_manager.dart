import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdManager extends StatefulWidget {
  final bool showBanner;
  final bool showInterstitial;
  final String? bannerAdUnitId;
  final String? interstitialAdUnitId;
  final String interstitialCooldownKey;

  const AdManager({
    super.key,
    this.showBanner = true,
    this.showInterstitial = false,
    this.bannerAdUnitId,
    this.interstitialAdUnitId,
    this.interstitialCooldownKey = 'lastInterstitialAdShownTime'
  });

  @override
  State<AdManager> createState() => _AdManagerState();
}

class _AdManagerState extends State<AdManager> {
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    if (widget.showBanner && widget.bannerAdUnitId != null) {
      _loadBannerAd();
    }
    if (widget.showInterstitial && widget.interstitialAdUnitId != null) {
      _loadInterstitialAd();
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: widget.bannerAdUnitId!,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          ad.dispose();
          setState(() {
            _isBannerAdLoaded = false;
          });
        },
      ),
    )..load();
  }

  void _loadInterstitialAd() async {
    final prefs = await SharedPreferences.getInstance();
    final lastAdShown = prefs.getInt(widget.interstitialCooldownKey) ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    const fiveMinutesInMillis = 5 * 60 * 1000; // 5 menit dalam milidetik

    if (currentTime - lastAdShown < fiveMinutesInMillis) {
      debugPrint('Interstitial ad not shown, less than 5 minutes since last show for key: ${widget.interstitialCooldownKey}');
      return;
    }

    InterstitialAd.load(
      adUnitId: widget.interstitialAdUnitId!,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              prefs.setInt(widget.interstitialCooldownKey, DateTime.now().millisecondsSinceEpoch);
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              debugPrint('InterstitialAd failed to show: $error');
            },
          );
          _interstitialAd!.show();
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showBanner && _isBannerAdLoaded && _bannerAd != null) {
      return Container(
          color: Colors.white,
        child: 
        Padding(
        padding: const EdgeInsets.only(bottom: 16, top: 12),
        child: SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      )
      );
    } else {
      return const SizedBox.shrink(); // Widget kosong jika tidak ada banner
    }
  }
}