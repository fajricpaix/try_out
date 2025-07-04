import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:try_out/widgets/ads/ads_constant.dart';
import 'package:try_out/widgets/ads/ads_manager.dart';

class ReadTipsScreen extends StatefulWidget {
  final String pdfSource;
  final bool isNetwork;
  final String title; // New: Add title parameter

  const ReadTipsScreen({
    super.key,
    required this.pdfSource,
    this.isNetwork = false,
    required this.title, // New: Make title required
  });

  @override
  State<ReadTipsScreen> createState() => _ReadTipsScreenState();
}

class _ReadTipsScreenState extends State<ReadTipsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)), // Use widget.title here
        backgroundColor: const Color(0xFF5E00B0),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: widget.isNetwork
          ? SfPdfViewer.network(widget.pdfSource)
          : SfPdfViewer.asset(widget.pdfSource),
      // Gunakan AdManager untuk menampilkan banner ad
      bottomNavigationBar: AdManager(
        showBanner: true,
        bannerAdUnitId: AdsConstants.bannerAdUnitId, // Gunakan ID dari constants
      ),
    );
  }
}