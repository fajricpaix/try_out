import 'package:firebase_database/firebase_database.dart'; // Re-added Firebase Database import
import 'package:flutter/material.dart';
import 'package:try_out/views/quetions/quiz.dart';
import 'package:try_out/widgets/ads/ads_constant.dart';
import 'package:try_out/widgets/ads/ads_manager.dart';
import 'dart:math';

class DashboardQuetionView extends StatefulWidget {
  final String? level;
  final String? initialCategory; // e.g. 'twk' | 'tiu' | 'tkp'
  final dynamic
  initialPackage; // pass a specific package object directly

  const DashboardQuetionView({
    super.key,
    this.level,
    this.initialCategory,
    this.initialPackage,
  });

  @override
  State<DashboardQuetionView> createState() => _DashboardQuetionViewState();
}

class _DashboardQuetionViewState extends State<DashboardQuetionView> {
  Map<String, dynamic>? quizData;
  bool _isLoading = true;
  String _error = '';
  String? _selectedQuizKey;
  String?
  _forcedCategory; // when provided, only show questions for this category

  // New: batches for 5 latihan, 30 soal each
  List<List<dynamic>> _latihanBatches = [];
  int _selectedLatihanIndex = 0;

  @override
  void initState() {
    super.initState();
    _forcedCategory = widget.initialCategory;
    // If an initial package was provided, use it directly and skip network load
    if (widget.initialPackage != null) {
      final Map<String, dynamic> normalizedInitialPackage =
          _normalizePackage(widget.initialPackage, widget.initialCategory);
      quizData = {
        'package_0': normalizedInitialPackage,
      };
      _selectedQuizKey = 'package_0';
      _isLoading = false;
      _prepareBatchesForSelectedQuiz();
    } else {
      _loadQuizData();
    }
  }

  List<dynamic> _toListFromDynamic(dynamic value) {
    if (value is List) {
      return value.where((e) => e != null).toList();
    }
    if (value is Map) {
      return value.values.where((e) => e != null).toList();
    }
    return [];
  }

  Map<String, dynamic> _normalizePackage(dynamic raw, String? category) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }

    // If raw package is list/map-indexed questions, wrap it under category key.
    final normalized = <String, dynamic>{
      'title': widget.level,
      'desc': '',
    };
    if (category != null && category.isNotEmpty) {
      normalized[category] = _toListFromDynamic(raw);
    }
    return normalized;
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
          _prepareBatchesForSelectedQuiz();
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
    // If the selected package uses a 'category' list (older format)
    final List<dynamic>? categories =
        selectedPackage['category'] as List<dynamic>?;

    if (categories != null) {
      for (var category in categories.where((e) => e != null && e is Map)) {
        final Map<String, dynamic> categoryMap = Map<String, dynamic>.from(
          category as Map,
        );
        final String catTitle = (categoryMap['title'] as String? ?? '')
            .toLowerCase();
        if (_forcedCategory != null) {
          if (catTitle == _forcedCategory &&
              categoryMap.containsKey('quiz') &&
              categoryMap['quiz'] is List) {
            allQuizzes.addAll(
              (categoryMap['quiz'] as List).where((q) => q != null),
            );
          }
        } else {
          if (categoryMap.containsKey('quiz') && categoryMap['quiz'] is List) {
            allQuizzes.addAll(
              (categoryMap['quiz'] as List).where((q) => q != null),
            );
          }
        }
      }
      return allQuizzes;
    }

    // If no 'category' list, support packages that store categories as keys (twk/tiu/tkp)
    for (final cat in ['twk', 'tiu', 'tkp']) {
      if (_forcedCategory != null && _forcedCategory != cat) continue;
      if (selectedPackage.containsKey(cat)) {
        allQuizzes.addAll(_toListFromDynamic(selectedPackage[cat]));
      }
    }

    return allQuizzes;
  }



  // Determine batch size depending on category
  int _determineBatchSize(Map<String, dynamic>? selectedPackage) {
    const Map<String, int> sizeMap = {'twk': 30, 'tiu': 35, 'tkp': 45};
    // If user forced a category (via initialCategory), use that mapping
    if (_forcedCategory != null && sizeMap.containsKey(_forcedCategory)) {
      return sizeMap[_forcedCategory] as int;
    }

    if (selectedPackage == null) return 30;

    // If package contains exactly one non-empty category key, use that mapping
    int found = 0;
    String lastKey = '';
    for (final cat in ['twk', 'tiu', 'tkp']) {
      if (selectedPackage.containsKey(cat) && selectedPackage[cat] is List && (selectedPackage[cat] as List).isNotEmpty) {
        found++;
        lastKey = cat;
      }
    }
    if (found == 1 && sizeMap.containsKey(lastKey)) {
      return sizeMap[lastKey] as int;
    }

    // Default fallback
    return 30;
  }

  // Prepare 5 latihan batches (variable soal per latihan depending on category)
  void _prepareBatchesForSelectedQuiz() {
    final selected = _selectedQuizKey != null ? quizData![_selectedQuizKey!] as Map<String, dynamic>? : null;
    final List<dynamic> allQuizzes = selected != null ? _getAllQuizzes(selected) : [];
    final List<dynamic> shuffled = List<dynamic>.from(allQuizzes);
    shuffled.shuffle();
    final int batchSize = _determineBatchSize(selected);
    _latihanBatches = [];
    final int total = shuffled.length;
    for (int i = 0; i < 5; i++) {
      if (total == 0) {
        _latihanBatches.add([]);
        continue;
      }
      // create a fresh shuffle for each latihan and take up to batchSize items
      final List<dynamic> tmp = List<dynamic>.from(shuffled);
      tmp.shuffle();
      final int take = min(batchSize, tmp.length);
      _latihanBatches.add(tmp.sublist(0, take));
    }
    // keep previously selected index if valid, otherwise reset to 0
    if (_selectedLatihanIndex >= _latihanBatches.length || _selectedLatihanIndex < 0) {
      _selectedLatihanIndex = 0;
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

    final int selectedLatihanCount = _latihanBatches.isNotEmpty
        ? _latihanBatches[_selectedLatihanIndex].length
        : _getAllQuizzes(selectedQuiz).length;

    return Scaffold(
      backgroundColor: const Color(0xFF6A5AE0),
      appBar: AppBar(
        title: Text(
          widget.level != null && widget.level!.isNotEmpty ? '${widget.level}' : '',
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
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
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
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: _selectedLatihanIndex,
                          dropdownColor: Colors.white,
                          style: const TextStyle(
                            color: Color(0xFF6A5AE0),
                            fontWeight: FontWeight.w600,
                          ),
                          iconEnabledColor: const Color(0xFF6A5AE0),
                          onChanged: (int? newValue) {
                            setState(() {
                              _selectedLatihanIndex = newValue ?? 0;
                            });
                          },
                          items: List<DropdownMenuItem<int>>.generate(5, (i) {
                            final int count = _latihanBatches.length > i ? _latihanBatches[i].length : 0;
                            final selectedPackage = _selectedQuizKey != null ? quizData![_selectedQuizKey!] as Map<String, dynamic>? : null;
                            String prefix;
                            if (_forcedCategory != null) {
                              prefix = _forcedCategory!.toUpperCase();
                            } else if (selectedPackage != null) {
                              final List<String> present = [];
                              for (final c in ['twk', 'tiu', 'tkp']) {
                                if (selectedPackage.containsKey(c) && selectedPackage[c] is List && (selectedPackage[c] as List).isNotEmpty) {
                                  present.add(c.toUpperCase());
                                }
                              }
                              if (present.isEmpty) {
                                prefix = 'Latihan';
                              } else if (present.length == 1) {
                                prefix = present.first;
                              } else {
                                prefix = present.join('/');
                              }
                            } else {
                              prefix = 'Latihan';
                            }

                            return DropdownMenuItem<int>(
                              value: i,
                              child: Text('Latihan $prefix ${i + 1} ($count Soal)'),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
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
                            const Text(
                              'Latihan Soal',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6A5AE0),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '$selectedLatihanCount Soal',
                              style: const TextStyle(
                                fontSize: 14,
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
                          selectedQuiz['desc'] as String? ?? 'Deskripsi Tidak Tersedia',
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
                        if (_latihanBatches.isNotEmpty && _latihanBatches[_selectedLatihanIndex].isNotEmpty) {
                          final List<dynamic> batch = List<dynamic>.from(_latihanBatches[_selectedLatihanIndex])..shuffle();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizView(quizData: batch),
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
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6A5AE0),
                        ),
                      ),
                    ),
                  ),

                  Text(
                    'Akan muncul iklan saat memulai latihan\n& diantara paket-paket soal',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  // your AdManager for the interstitial ad
                  AdManager(
                    showBanner: false,
                    showInterstitial: true,
                    interstitialAdUnitId: AdsConstants.interstitialAdUnitId,
                    interstitialCooldownKey: 'lastSimulationAdShownTime',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AdManager(
        showBanner: true,
        bannerAdUnitId: AdsConstants.bannerAdUnitId,
      ),
    );
  }
}
