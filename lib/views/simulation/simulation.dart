import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:try_out/views/tryout/try_out.dart';
import 'package:try_out/widgets/tools/box_quiz.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

class SimulationView extends StatefulWidget {
  const SimulationView({super.key});

  @override
  State<SimulationView> createState() => _SimulationViewState();
}

class _SimulationViewState extends State<SimulationView> {
  Map<String, dynamic> data = {};
  String? selectedKey;
  
  // Ads
  InterstitialAd? _interstitialAd;
  static const String _lastAdShownKey = 'lastSimulationAdShownTime'; // Key for SharedPreferences

  @override
  void initState() {
    super.initState();
    loadJson();
    _loadInterstitialAd(); // Attempt to load and show ad on init
  }

  void _loadInterstitialAd() async { // Made async to use SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final lastAdShown = prefs.getInt(_lastAdShownKey) ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    const fiveMinutesInMillis = 5 * 60 * 1000; // 5 minutes in milliseconds

    if (currentTime - lastAdShown < fiveMinutesInMillis) {
      debugPrint('Interstitial ad not shown yet, less than 5 minutes since last show.');
      return; // Don't show ad if less than 5 minutes have passed
    }

    InterstitialAd.load(
      // Dev ID
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', // TEST ID, replace with real one
      // Production ID
      // adUnitId = 'ca-app-pub-2602479093941928/9052001071';
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              // Update the last ad shown time after the ad is dismissed
              prefs.setInt(_lastAdShownKey, DateTime.now().millisecondsSinceEpoch);
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              debugPrint('InterstitialAd failed to show: $error');
            },
          );
          _interstitialAd!.show(); // Show ad if time constraint is met
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd failed to load: $error');
        },
      ),
    );
  }
  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  Future<void> loadJson() async {
  final String jsonStr = await rootBundle.loadString(
    'assets/json/try_out.json',
  );
  final Map<String, dynamic> rawJsonData = json.decode(jsonStr);

  // Access the 'cpns' key first
  final Map<String, dynamic>? cpnsData = rawJsonData['cpns'];

  Map<String, dynamic> filteredData = {};

  // Only proceed if 'cpnsData' is not null
  if (cpnsData != null) {
    cpnsData.forEach((key, value) {
      if (value is Map<String, dynamic> && value['type'] == 'simulasi') {
        filteredData[key] = value;
      }
    });
  }

  setState(() {
    data = filteredData;
    // Set selectedKey to the first key of the filtered data
    selectedKey = data.keys.isNotEmpty ? data.keys.first : null;
  });
}

  @override
  Widget build(BuildContext context) {
    if (selectedKey == null || data.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF6A5AE0),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final selectedData = data[selectedKey!];
    final jumlahSoal = selectedData['category'].fold(
      0,
      (sum, cat) => sum + (cat['quiz'] as List).length,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF6A5AE0),
      appBar: AppBar(
        title: const Text(
          'Simulasi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: const Color(0xFF6A5AE0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(22)),
        ),
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Pilih Tingkat Kesulitan Try Out',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 20, right: 20, top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              underline: const SizedBox(),
              isExpanded: true,
              value: selectedKey,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6A5AE0)),
              dropdownColor: Colors.white,
              style: const TextStyle(
                color: Color(0xFF6A5AE0),
                fontWeight: FontWeight.bold,
              ),
              items: data.entries.map((entry) {
                final level = entry.value['level'];
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(level),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedKey = value!;
                });
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Latihan Soal',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6A5AE0)),
                ),
                const SizedBox(height: 8),
                Text(
                  selectedData['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(selectedData['desc']),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BoxQuizComponents(
                  label: 'Jumlah Soal',
                  text: '$jumlahSoal Soal',
                ),
                const SizedBox(width: 16),
                BoxQuizComponents(
                  label: 'Durasi',
                  text: '${(selectedData['duration'] / 60).round()} Menit',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BoxQuizComponents(
                  label: 'Passing Grade',
                  text: '${selectedData['passing_grade']}/1000',
                ),
                const SizedBox(width: 16),
                BoxQuizComponents(
                  label: 'Tingkat Kesulitan',
                  text: selectedData['level'],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TryOutViews(data: selectedData),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Mulai Latihan Soal',
                style: TextStyle(fontSize: 16, color: Color(0xFF6A5AE0)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}