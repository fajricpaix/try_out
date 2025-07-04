import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:try_out/widgets/ads/ads_constant.dart';
import 'package:try_out/widgets/ads/ads_intertitial_button_back.dart';
import 'package:try_out/widgets/ads/ads_manager.dart';

class ReadTipsScreen extends StatefulWidget {
  final String pdfSource;
  final bool isNetwork;
  final String title;

  const ReadTipsScreen({
    super.key,
    required this.pdfSource,
    this.isNetwork = false,
    required this.title,
  });

  @override
  State<ReadTipsScreen> createState() => _ReadTipsScreenState();
}

class _ReadTipsScreenState extends State<ReadTipsScreen> {
  late InterstitialAdsBackButton _interstitialAdHelper;

  @override
  void initState() {
    super.initState();
    _interstitialAdHelper = InterstitialAdsBackButton(
      onAdDismissed: () {
        Navigator.of(context).pop();
      },
    );
    _interstitialAdHelper.loadAd();
  }

  @override
  void dispose() {
    _interstitialAdHelper.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    await _interstitialAdHelper.showAd();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title, style: const TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF5E00B0),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: widget.isNetwork
            ? SfPdfViewer.network(widget.pdfSource)
            : SfPdfViewer.asset(widget.pdfSource),
        bottomNavigationBar: AdManager(
          showBanner: true,
          bannerAdUnitId: AdsConstants.bannerAdUnitId,
        ),
      ),
    );
  }
}