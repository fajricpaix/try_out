import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:try_out/widgets/tools/quiz_preview.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class DashboardQuetionView extends StatefulWidget {
  final String level;

  const DashboardQuetionView({super.key, required this.level});

  @override
  State<DashboardQuetionView> createState() => _DashboardQuetionViewState();
}

class _DashboardQuetionViewState extends State<DashboardQuetionView> {
  Map<String, dynamic>? quizData;
  bool _isLoading = true;
  String _error = '';
  
  InterstitialAd? _interstitialAd;

  void _loadInterstitialAd() {
  InterstitialAd.load(
      // Dev ID
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', // TEST ID, replace with real one
      // Production ID
      // adUnitId = 'ca-app-pub-2602479093941928/9052001071';
    request: const AdRequest(),
    adLoadCallback: InterstitialAdLoadCallback(
      onAdLoaded: (InterstitialAd ad) {
        _interstitialAd = ad;
        _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            ad.dispose();
          },
        );
        _interstitialAd!.show(); // <-- tampilkan iklan saat sudah siap
      },
      onAdFailedToLoad: (LoadAdError error) {
        debugPrint('InterstitialAd failed to load: $error');
      },
    ),
  );
}

  @override
  void initState() {
    super.initState();
    _loadQuizData();
    _loadInterstitialAd();
  }

  @override
void dispose() {
  _interstitialAd?.dispose();
  super.dispose();
}

  Future<void> _loadQuizData() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/json/training.json',
      );
      final Map<String, dynamic> rawData = json.decode(response);

      final filteredData = <String, dynamic>{};
      for (final entry in rawData.entries) {
        if (entry.value['level'] == widget.level) {
          filteredData[entry.key] = entry.value;
        }
      }

      setState(() {
        quizData = filteredData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat soal: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF6A5AE0),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF6A5AE0),
        body: Center(
          child: Text(
            _error,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (quizData == null || quizData!.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF6A5AE0),
        body: const Center(
          child: Text(
            'Tidak ada soal untuk level ini.',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    final keys = quizData!.keys.toList();

    return DefaultTabController(
      length: keys.length,
      child: Scaffold(
        backgroundColor: const Color(0xFF6A5AE0),
        appBar: AppBar(
          title: Text(
            'Latihan Soal - ${widget.level}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: const Color(0xFF6A5AE0),
        ),
        body: Column(
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(top: 20, bottom: 12),
              child: Image.asset(
                'assets/training/question.webp',
                width: 250,
                height: 250,
              ),
            ),
            TabBar(
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white,
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(color: Colors.white, width: 2),
                insets: EdgeInsets.only(bottom: 8),
              ),
              dividerColor: Colors.transparent,
              tabs: keys.map((key) {
                final title = quizData![key]['title'] ?? key.toUpperCase();
                return Tab(text: title);
              }).toList(),
            ),
            Expanded(
              child: TabBarView(
                children: keys.map((key) {
                  final data = quizData![key];
                  return QuizPreviewTabContent(
                    title: data['title'] ?? '',
                    desc: data['desc'] ?? '',
                    level: data['level'] ?? '',
                    quizList: data['quiz'] ?? [],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
