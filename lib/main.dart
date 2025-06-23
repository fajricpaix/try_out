import 'package:flutter/material.dart';
import 'package:try_out/views/home/content/menu.dart';
import 'package:try_out/views/home/header/header.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // Import library AdMob

void main() {
  // binding Flutter initial before AdMob
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi Google Mobile Ads SDK
  MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CPNS Try Out 2025',
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late BannerAd _bannerAd;
  bool _isBannerAdLoaded = false;

  // Android Test ID: ca-app-pub-3940256099942544/6300978111
  final String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  // Production ID
  // final String bannerAdUnitId = 'ca-app-pub-2602479093941928/9052001071';

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner, // standar size for ads
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          // Callback ads if done to show
          setState(() {
            _isBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          // Callback ads if no show
          ad.dispose(); // Delet ads for lost perfomance
          setState(() {
            _isBannerAdLoaded = false; // Set to false for not showing
          });
        },
      ),
    )..load(); // Start ads process
  }

  @override
  void dispose() {
    // Important: Remove ads when widget not use for free perfomance
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5E00B0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 32.0),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Header(),
                  MenuContent(),
                ],
              ),
            ),
          ],
        ),
      ),
      // Add bottomNavigationBar for adsBanner
      bottomNavigationBar: _isBannerAdLoaded
          ? Container(
              color: Colors.white,
              width: _bannerAd.size.width.toDouble(),
              height: _bannerAd.size.height.toDouble(),
              alignment: Alignment.center,
              child: AdWidget(ad: _bannerAd), // Widget to show ads
            )
          : const SizedBox.shrink(), // If ads not show, show empty widget
    );
  }
}