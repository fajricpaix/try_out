import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:try_out/views/quetions/quiz.dart';
import 'package:try_out/widgets/tools/box_quiz.dart';

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
  String? _selectedQuizKey;

  InterstitialAd? _interstitialAd;
  static const String _lastAdShownKey = 'lastAdShownTime'; // Key for SharedPreferences

  void _loadInterstitialAd() async {
    final prefs = await SharedPreferences.getInstance();
    final lastAdShown = prefs.getInt(_lastAdShownKey) ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    const fiveMinutesInMillis = 5 * 60 * 1000; // 5 minutes in milliseconds

    if (currentTime - lastAdShown < fiveMinutesInMillis) {
      debugPrint('Interstitial ad not shown, less than 5 minutes since last show.');
      return; // Don't show ad if less than 5 minutes have passed
    }

    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', // TEST ID, replace with real one
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              prefs.setInt(_lastAdShownKey, DateTime.now().millisecondsSinceEpoch);
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('InterstitialAd failed to show: $error');
              ad.dispose();
            },
          );
          _interstitialAd!.show();
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
    final String response = await rootBundle.loadString('assets/json/try_out.json');
    final Map<String, dynamic> rawData = json.decode(response);

    // Access the 'cpns' key first
    final Map<String, dynamic>? cpnsData = rawData['cpns'];

    final filteredData = <String, dynamic>{};

    if (cpnsData != null) {
      for (final entry in cpnsData.entries) { // Iterate through the entries within 'cpns'
        if (entry.value is Map<String, dynamic> &&
            entry.value.containsKey('level') &&
            entry.value.containsKey('type')) {
          if (entry.value['level'] == widget.level &&
              entry.value['type'] == 'training') {
            filteredData[entry.key] = entry.value;
          }
        }
      }
    }

    setState(() {
      quizData = filteredData;
      _isLoading = false;
      // Set the initial selected quiz to the first one if data exists
      if (quizData != null && quizData!.isNotEmpty) {
        _selectedQuizKey = quizData!.keys.first;
      }
    });
  } catch (e) {
    setState(() {
      _error = 'Gagal memuat soal: $e';
      _isLoading = false;
    });
  }
}

  // Helper function to get all questions from all categories of a selected package
  List<dynamic> _getAllQuizzes(Map<String, dynamic> selectedPackage) {
    List<dynamic> allQuizzes = [];
    final List<dynamic>? categories = selectedPackage['category'];

    if (categories != null) {
      for (var category in categories) {
        if (category is Map<String, dynamic> && category.containsKey('quiz')) {
          allQuizzes.addAll(category['quiz']);
        }
      }
    }
    return allQuizzes;
  }

  // New helper function to get question counts by category
  Map<String, int> _getCategoryQuestionCounts(Map<String, dynamic> selectedPackage) {
  // Initialize counts for each category with 0
  Map<String, int> counts = {'twk': 0, 'tiu': 0, 'tkp': 0};
  final List<dynamic>? categories = selectedPackage['category'];

  if (categories != null) {
    for (var category in categories) {
      if (category is Map<String, dynamic> && category.containsKey('title') && category.containsKey('quiz')) {
        String categoryTitle = category['title']; // Get the category name (e.g., "twk", "tiu", "tkp")
        if (counts.containsKey(categoryTitle)) {
          // If the category name matches, count the number of items in its 'quiz' list
          counts[categoryTitle] = (category['quiz'] as List).length;
        }
      }
    }
  }
  return counts; // Returns a map like {'twk': 2, 'tiu': 1, 'tkp': 1}
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
        appBar: AppBar(
        title: Text(
          'Kembali',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: const Color(0xFF6A5AE0),
      ),
        body: const Center(
          child: Text(
            'Tidak ada soal untuk level ini.',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    final keys = quizData!.keys.toList();
    final selectedQuiz = _selectedQuizKey != null ? quizData![_selectedQuizKey!] : null;

    final Map<String, int> categoryCounts = _getCategoryQuestionCounts(selectedQuiz);

    // Guard against null selectedQuiz if somehow _selectedQuizKey doesn't point to valid data
    if (selectedQuiz == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF6A5AE0),
        body: const Center(
          child: Text(
            'Paket soal tidak ditemukan. Silakan coba lagi.',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF6A5AE0),
      appBar: AppBar(
        title: Text(
          'Latihan Soal - ${widget.level}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
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
          // Dropdown for selecting quizzes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedQuizKey,
                  dropdownColor: Colors.white,
                  style: const TextStyle(
                    color: Color(0xFF6A5AE0),
                    fontWeight: FontWeight.w600,
                  ),
                  iconEnabledColor: const Color(0xFF6A5AE0),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedQuizKey = newValue;
                    });
                  },
                  items: keys.map<DropdownMenuItem<String>>((String key) {
                    final int index = keys.indexOf(key) + 1;
                    final title = quizData![key]['level'] ?? key.toUpperCase();
                    return DropdownMenuItem<String>(
                      value: key,
                      child: Text('Soal - $title $index'),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Latihan Soal',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6A5AE0),
                              fontWeight: FontWeight.w600
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        selectedQuiz['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(selectedQuiz['desc']),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  margin: EdgeInsets.only(bottom: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Jumlah Soal',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BoxQuizComponents(
                        label: 'TWK',
                        text: '${categoryCounts['twk']} Soal',
                      ),
                      const SizedBox(width: 8),
                      BoxQuizComponents(
                        label: 'TIU',
                        text: '${categoryCounts['tiu']} Soal',
                      ),
                      const SizedBox(width: 8),
                      BoxQuizComponents(
                        label: 'TKP',
                        text: '${categoryCounts['tkp']} Soal',
                      )
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      final List<dynamic> allQuizzes = _getAllQuizzes(selectedQuiz);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuizView(
                            quizData: allQuizzes
                          ),
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
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6A5AE0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}