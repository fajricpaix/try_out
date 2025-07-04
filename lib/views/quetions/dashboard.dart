import 'package:firebase_database/firebase_database.dart'; // Re-added Firebase Database import
import 'package:flutter/material.dart';
import 'package:try_out/views/quetions/quiz.dart';
import 'package:try_out/widgets/ads/ads_constant.dart';
import 'package:try_out/widgets/ads/ads_manager.dart';
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

  @override
  void initState() {
    super.initState();
    _loadQuizData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadQuizData() async {
    try {
      final DatabaseReference cpnsRef = FirebaseDatabase.instance.ref('cpns');
      final DataSnapshot snapshot = await cpnsRef.get();

      final filteredData = <String, dynamic>{};
      int packageCounter = 0;

      if (snapshot.exists && snapshot.value != null) {
        final dynamic rawValue = snapshot.value;
        if (rawValue is List) {
          final List<dynamic> cpnsList = rawValue
              .where((e) => e != null && e is Map)
              .toList();

          for (final dynamic item in cpnsList) {
            final Map<String, dynamic> packageData = Map<String, dynamic>.from(
              item as Map,
            );

            if (packageData.containsKey('level') &&
                packageData.containsKey('type')) {
              if (packageData['level'] == widget.level &&
                  packageData['type'] == 'training') {
                final String generatedKey = 'package_${packageCounter++}';
                filteredData[generatedKey] = packageData;
              }
            }
          }
        } else {
          debugPrint(
            "Firebase node 'cpns_quizzes' is not a List. It's a ${rawValue.runtimeType}.",
          );
          _error = "Kesalahan format data Firebase: 'cpns_quizzes' bukan list.";
        }
      } else {
        debugPrint(
          "Firebase snapshot does not exist or value is null at 'cpns_quizzes'. Check your Firebase path and data.",
        );
        _error =
            "Tidak ada data soal ditemukan di Firebase. Cek koneksi & struktur data Anda.";
      }

      setState(() {
        quizData = filteredData;
        _isLoading = false;
        if (quizData != null && quizData!.isNotEmpty) {
          _selectedQuizKey = quizData!.keys.first;
        } else if (_error.isEmpty) {
          _error = 'Tidak ada paket soal yang ditemukan untuk level ini.';
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat soal: $e';
        _isLoading = false;
        debugPrint('Error loading quiz data from Firebase: $e');
      });
    }
  }

  List<dynamic> _getAllQuizzes(Map<String, dynamic> selectedPackage) {
    List<dynamic> allQuizzes = [];
    final List<dynamic>? categories =
        selectedPackage['category'] as List<dynamic>?;

    if (categories != null) {
      for (var category in categories.where((e) => e != null && e is Map)) {
        final Map<String, dynamic> categoryMap = Map<String, dynamic>.from(
          category as Map,
        );
        if (categoryMap.containsKey('quiz') && categoryMap['quiz'] is List) {
          allQuizzes.addAll(
            (categoryMap['quiz'] as List).where((q) => q != null),
          );
        }
      }
    }
    return allQuizzes;
  }

  Map<String, int> _getCategoryQuestionCounts(
    Map<String, dynamic>? selectedPackage,
  ) {
    Map<String, int> counts = {'twk': 0, 'tiu': 0, 'tkp': 0};

    if (selectedPackage == null) {
      return counts;
    }

    final List<dynamic>? categories =
        selectedPackage['category'] as List<dynamic>?;

    if (categories != null) {
      for (var category in categories.where((e) => e != null && e is Map)) {
        final Map<String, dynamic> categoryMap = Map<String, dynamic>.from(
          category as Map,
        );
        if (categoryMap.containsKey('title') &&
            categoryMap.containsKey('quiz') &&
            categoryMap['quiz'] is List) {
          String categoryTitle = (categoryMap['title'] as String).toLowerCase();
          if (counts.containsKey(categoryTitle)) {
            counts[categoryTitle] = (categoryMap['quiz'] as List)
                .where((q) => q != null)
                .length;
          }
        }
      }
    }
    return counts;
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 48),
              const SizedBox(height: 16),
              Text(
                _error,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Kembali ke Halaman Sebelumnya',
                    style: TextStyle(fontSize: 16, color: Color(0xFF6A5AE0)),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final keys = quizData!.keys.toList();
    final selectedQuiz = _selectedQuizKey != null
        ? quizData![_selectedQuizKey!]
        : null;

    if (selectedQuiz == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF6A5AE0),
        body: const Center(
          child: Text(
            'Paket soal tidak ditemukan atau tidak valid. Silakan coba lagi.',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    final Map<String, int> categoryCounts = _getCategoryQuestionCounts(
      selectedQuiz,
    );

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
                    final package = quizData![key];
                    final String displayText = package['level'] as String? ?? 'Level $index';
                    return DropdownMenuItem<String>(
                      value: key,
                      child: Text('Soal - $displayText $index'),
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
                        children: const [
                          Text(
                            'Latihan Soal',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6A5AE0),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        selectedQuiz['title'] as String? ??
                            'Judul Tidak Tersedia',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedQuiz['desc'] as String? ??
                            'Deskripsi Tidak Tersedia',
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Jumlah Soal',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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
                        text: '${categoryCounts['twk'] ?? 0} Soal',
                      ),
                      const SizedBox(width: 8),
                      BoxQuizComponents(
                        label: 'TIU',
                        text: '${categoryCounts['tiu'] ?? 0} Soal',
                      ),
                      const SizedBox(width: 8),
                      BoxQuizComponents(
                        label: 'TKP',
                        text: '${categoryCounts['tkp'] ?? 0} Soal',
                      ),
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
                      final List<dynamic> allQuizzes = _getAllQuizzes(
                        selectedQuiz,
                      );
                      if (allQuizzes.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuizView(quizData: allQuizzes),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Tidak ada soal dalam paket terpilih.',
                            ),
                          ),
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
                      'Mulai Latihan Soal',
                      style: TextStyle(fontSize: 16, color: Color(0xFF6A5AE0)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // your AdManager for the interstitial ad
          const AdManager(
            showBanner: false,
            showInterstitial: true,
            interstitialAdUnitId: AdsConstants.interstitialAdUnitId,
            interstitialCooldownKey: 'lastSimulationAdShownTime',
          ),
        ],
      ),
    );
  }
}
