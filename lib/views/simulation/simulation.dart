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
  bool _isLoading = true; // Added loading state

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
    try {
      final String jsonStr = await rootBundle.loadString(
        'assets/json/try_out.json',
      );
      final Map<String, dynamic> rawJsonData = json.decode(jsonStr);

      // Expect 'cpns' to be a List of dynamic
      final List<dynamic>? cpnsList = rawJsonData['cpns'];

      Map<String, dynamic> filteredData = {};
      int packageCounter = 0; // To generate unique keys for the map

      if (cpnsList != null) {
        // Filter out null values and then process valid maps
        for (final dynamic item in cpnsList.where((e) => e != null)) {
          if (item is Map<String, dynamic>) {
            // 'item' is already the quiz package data (e.g., {"level": "Mudah", "type": "simulasi", ...})
            final Map<String, dynamic> packageData = item; 

            if (packageData.containsKey('type') && packageData['type'] == 'simulasi') {
              // Generate a unique key for this simulation package
              final String generatedKey = 'simulasi_${packageCounter++}';
              filteredData[generatedKey] = packageData;
            }
          }
        }
      }

      setState(() {
        data = filteredData;
        selectedKey = data.keys.isNotEmpty ? data.keys.first : null;
        _isLoading = false; // Set loading to false once data is loaded
      });
    } catch (e) {
      debugPrint('Error loading JSON: $e');
      setState(() {
        _isLoading = false; // Set loading to false even on error
        // Optionally set an error message to display
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

    if (selectedKey == null || data.isEmpty) {
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
        ),
        body: const Center(
          child: Text(
            'Tidak ada data simulasi yang tersedia.',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    final selectedData = data[selectedKey!];
    
    // Safely calculate jumlahSoal
    int jumlahSoal = 0;
    if (selectedData != null && selectedData.containsKey('category') && selectedData['category'] is List) {
      for (var cat in selectedData['category']) {
        if (cat is Map<String, dynamic> && cat.containsKey('quiz') && cat['quiz'] is List) {
          jumlahSoal += (cat['quiz'] as List).length;
        }
      }
    }

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
                final level = entry.value['level'] ?? 'Unknown Level'; // Provide a fallback
                // You can add a number here if each level repeats (e.g., "Mudah 1", "Mudah 2")
                // For simulations, it's often just the level like "Mudah", "Sedang"
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
                  'Simulasi Soal', // Changed from 'Latihan Soal'
                  style: TextStyle(fontSize: 12, color: Color(0xFF6A5AE0)),
                ),
                const SizedBox(height: 8),
                Text(
                  selectedData['title'] ?? 'Judul Tidak Tersedia', // Added null check
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(selectedData['desc'] ?? 'Deskripsi Tidak Tersedia'), // Added null check
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
                  text: '${selectedData['passing_grade'] ?? 'N/A'}/1000', // Added null check
                ),
                const SizedBox(width: 16),
                BoxQuizComponents(
                  label: 'Tingkat Kesulitan',
                  text: selectedData['level'] ?? 'N/A', // Added null check
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ElevatedButton(
              onPressed: () {
                if (selectedData != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TryOutViews(data: selectedData),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tidak ada data simulasi yang dipilih.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Mulai Simulasi', // Changed from 'Mulai Latihan Soal'
                style: TextStyle(fontSize: 16, color: Color(0xFF6A5AE0)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}