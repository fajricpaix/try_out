import 'package:firebase_database/firebase_database.dart'; // Firebase Realtime Database
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:try_out/services/energy_service.dart';
import 'package:try_out/views/tryout/try_out.dart'; // Ensure this path is correct for TryOutViews
import 'package:try_out/widgets/ads/ads_constant.dart';
import 'package:try_out/widgets/ads/ads_manager.dart';
import 'package:try_out/widgets/tools/box_quiz.dart'; // Ensure this path is correct for BoxQuizComponents
import 'dart:math';

class SimulationView extends StatefulWidget {
  const SimulationView({super.key});

  @override
  State<SimulationView> createState() => _SimulationViewState();
}

class _SimulationViewState extends State<SimulationView> {
  Map<String, dynamic> data = {};
  String? selectedKey;
  bool _isLoading = true; // Added loading state

  // Prepared 5 simulation variants per selected simulation (each is a Map<String, dynamic> matching TryOutViews data shape)
  List<Map<String, dynamic>> _simulationVariants = [];
  int _selectedSimulationIndex = 0;

  // Firebase Database reference
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _loadSimulationsFromFirebase(); // Load data from Firebase
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadSimulationsFromFirebase() async {
    try {
      final DatabaseEvent event = await _databaseRef.child('cpns').once();
      final DataSnapshot snapshot = event.snapshot;

      Map<String, dynamic> filteredData = {};
      int packageCounter = 0;

      if (snapshot.value != null) {
        if (snapshot.value is List) {
          final List<dynamic> cpnsList = snapshot.value as List<dynamic>;

          for (final dynamic item in cpnsList.where((e) => e != null)) {
            if (item is Map) {
              final Map<String, dynamic> packageData =
                  Map<String, dynamic>.from(item);

              // No longer filter by 'type'; include all packages as simulations
              final String generatedKey = 'simulasi_${packageCounter++}';
              filteredData[generatedKey] = packageData;
            }
          }
        } else if (snapshot.value is Map) {
          (snapshot.value as Map<dynamic, dynamic>).forEach((key, value) {
            if (value is Map) {
              final Map<String, dynamic> packageData =
                  Map<String, dynamic>.from(value);
              // No longer filter by 'type'; include all packages as simulations
              filteredData[key.toString()] = packageData;
            }
          });
        }
      }

      // If Firebase contains separate packages for TWK/TIU/TKP (as in your JSON export),
      // combine them into a single CPNS package so a full simulation (TWK+TIU+TKP) can be run.
      bool hasFullPackage = false;
      for (final v in filteredData.values) {
        if (v is Map) {
          final dynamic cats = v['category'];
          if (cats is List) {
            final titles = cats
                .where((e) => e is Map && e.containsKey('title'))
                .map((e) => (e['title'] as String).toLowerCase())
                .toList();
            if (titles.any((t) => t.contains('twk')) &&
                titles.any((t) => t.contains('tiu')) &&
                titles.any((t) => t.contains('tkp'))) {
              hasFullPackage = true;
              break;
            }
          } else {
            if (v.containsKey('twk') &&
                v.containsKey('tiu') &&
                v.containsKey('tkp')) {
              hasFullPackage = true;
              break;
            }
          }
        }
      }

      if (!hasFullPackage) {
        final Map<String, List<dynamic>> combinedPools = {
          'twk': [],
          'tiu': [],
          'tkp': [],
        };

        for (final v in filteredData.values) {
          if (v is Map) {
            if (v.containsKey('twk') &&
                v['twk'] is List &&
                combinedPools['twk']!.isEmpty) {
              combinedPools['twk'] = List<dynamic>.from(v['twk'] as List);
            }
            if (v.containsKey('tiu') &&
                v['tiu'] is List &&
                combinedPools['tiu']!.isEmpty) {
              combinedPools['tiu'] = List<dynamic>.from(v['tiu'] as List);
            }
            if (v.containsKey('tkp') &&
                v['tkp'] is List &&
                combinedPools['tkp']!.isEmpty) {
              combinedPools['tkp'] = List<dynamic>.from(v['tkp'] as List);
            }

            final dynamic cats = v['category'];
            if (cats is List) {
              for (var c in cats.where((e) => e != null)) {
                if (c is Map) {
                  final String title = (c['title'] as String? ?? '')
                      .toLowerCase();
                  if (title.contains('twk') &&
                      combinedPools['twk']!.isEmpty &&
                      c['quiz'] is List) {
                    combinedPools['twk'] = List<dynamic>.from(c['quiz']);
                  }
                  if (title.contains('tiu') &&
                      combinedPools['tiu']!.isEmpty &&
                      c['quiz'] is List) {
                    combinedPools['tiu'] = List<dynamic>.from(c['quiz']);
                  }
                  if (title.contains('tkp') &&
                      combinedPools['tkp']!.isEmpty &&
                      c['quiz'] is List) {
                    combinedPools['tkp'] = List<dynamic>.from(c['quiz']);
                  }
                }
              }
            }
          }
        }

        if (combinedPools['twk']!.isNotEmpty ||
            combinedPools['tiu']!.isNotEmpty ||
            combinedPools['tkp']!.isNotEmpty) {
          final Map<String, dynamic> combined = {};
          combined['title'] = 'Simulasi CPNS';
          final List<Map<String, dynamic>> cats = [];
          if (combinedPools['twk']!.isNotEmpty) {
            cats.add({'title': 'TWK', 'quiz': combinedPools['twk']});
          }
          if (combinedPools['tiu']!.isNotEmpty) {
            cats.add({'title': 'TIU', 'quiz': combinedPools['tiu']});
          }
          if (combinedPools['tkp']!.isNotEmpty) {
            cats.add({'title': 'TKP', 'quiz': combinedPools['tkp']});
          }
          combined['category'] = cats;
          combined['duration'] = 100 * 60;
          filteredData['simulasi_cpns_all'] = combined;
        }
      }

      setState(() {
        data = filteredData;
        // If we created a combined CPNS package, prefer it by default
        selectedKey = data.containsKey('simulasi_cpns_all')
            ? 'simulasi_cpns_all'
            : (data.keys.isNotEmpty ? data.keys.first : null);
        _isLoading = false;
        if (selectedKey != null) {
          _prepareSimulationVariants(data[selectedKey]);
        }
      });
    } catch (e) {
      debugPrint('Error loading data from Firebase: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Extract pools for twk/tiu/tkp from selectedData
  Map<String, List<dynamic>> _extractCategoryPools(
    Map<String, dynamic>? selectedData,
  ) {
    final Map<String, List<dynamic>> pools = {'twk': [], 'tiu': [], 'tkp': []};
    if (selectedData == null) return pools;

    final dynamic categories = selectedData['category'];
    if (categories is List) {
      for (var cat in categories.where((e) => e != null)) {
        if (cat is Map) {
          final Map<String, dynamic> categoryMap = Map<String, dynamic>.from(
            cat,
          );
          final String title = (categoryMap['title'] as String? ?? '')
              .toLowerCase();
          if (categoryMap.containsKey('quiz') && categoryMap['quiz'] is List) {
            if (title.contains('twk')) {
              pools['twk'] = List<dynamic>.from(categoryMap['quiz']);
            } else if (title.contains('tiu')) {
              pools['tiu'] = List<dynamic>.from(categoryMap['quiz']);
            } else if (title.contains('tkp')) {
              pools['tkp'] = List<dynamic>.from(categoryMap['quiz']);
            }
          }
        }
      }
    } else if (selectedData.containsKey('twk') ||
        selectedData.containsKey('tiu') ||
        selectedData.containsKey('tkp')) {
      for (final cat in ['twk', 'tiu', 'tkp']) {
        if (selectedData.containsKey(cat) && selectedData[cat] is List) {
          pools[cat] = List<dynamic>.from(selectedData[cat] as List<dynamic>);
        }
      }
    }

    return pools;
  }

  // Prepare 5 simulation variants. Each variant contains sampled quizzes: 30 TWK, 35 TIU, 45 TKP (or fewer if pool is small).
  void _prepareSimulationVariants(Map<String, dynamic>? selectedData) {
    _simulationVariants = [];
    _selectedSimulationIndex = 0;
    if (selectedData == null) return;

    final pools = _extractCategoryPools(selectedData);
    final Map<String, int> sizes = {'twk': 30, 'tiu': 35, 'tkp': 45};

    for (int i = 0; i < 5; i++) {
      final List<Map<String, dynamic>> categories = [];

      for (final catKey in ['twk', 'tiu', 'tkp']) {
        final pool = List<dynamic>.from(pools[catKey]!);
        pool.shuffle();
        final int take = min(sizes[catKey]!, pool.length);
        final List<dynamic> sample = pool.sublist(0, take);
        categories.add({'title': catKey.toUpperCase(), 'quiz': sample});
      }

      // Build variant map cloning essential metadata from selectedData
      final Map<String, dynamic> variant = Map<String, dynamic>.from(
        selectedData,
      );
      variant['category'] = categories;
      // Force duration to 100 minutes for each simulation (100 * 60 seconds)
      variant['duration'] = 100 * 60;

      _simulationVariants.add(variant);
    }
  }

  // Helper to compute counts (TWK/TIU/TKP/total) from a variant-like map
  Map<String, int> _getCountsFromVariantData(Map<String, dynamic>? variant) {
    final Map<String, int> counts = {'twk': 0, 'tiu': 0, 'tkp': 0, 'total': 0};
    if (variant == null) return counts;
    final dynamic cats = variant['category'];
    if (cats is List) {
      for (var c in cats) {
        if (c is Map &&
            c.containsKey('title') &&
            c.containsKey('quiz') &&
            c['quiz'] is List) {
          final String title = (c['title'] as String).toLowerCase();
          final int len = (c['quiz'] as List).length;
          if (title.contains('twk')) {
            counts['twk'] = len;
          } else if (title.contains('tiu')) {
            counts['tiu'] = len;
          } else if (title.contains('tkp')) {
            counts['tkp'] = len;
          }
          counts['total'] = counts['total']! + len;
        }
      }
    } else {
      for (final key in ['twk', 'tiu', 'tkp']) {
        if (variant.containsKey(key) && variant[key] is List) {
          counts[key] = (variant[key] as List).length;
          counts['total'] = counts['total']! + counts[key]!;
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
        titleSpacing: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Pilih Simulasi Try Out Anda',
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
                  child: Column(
                    children: [
                      DropdownButton<int>(
                        underline: const SizedBox(),
                        isExpanded: true,
                        value: _selectedSimulationIndex,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF6A5AE0),
                        ),
                        dropdownColor: Colors.white,
                        style: const TextStyle(
                          color: Color(0xFF6A5AE0),
                          fontWeight: FontWeight.bold,
                        ),
                        items: List<DropdownMenuItem<int>>.generate(5, (i) {
                          return DropdownMenuItem<int>(
                            value: i,
                            child: Text('Simulasi CPNS ${i + 1}'),
                          );
                        }),
                        onChanged: (v) {
                          setState(() {
                            _selectedSimulationIndex = v ?? 0;
                          });
                        },
                      ),
                    ],
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
                      const Text(
                        'Simulasi Soal',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6A5AE0),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'TWK, TIU, TKP',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Persiapan Ujian CPNS dengan simulasi soal TWK, TIU, dan TKP yang komprehensif untuk meningkatkan kemampuan Anda.',
                      ),
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
                        text:
                            '${_simulationVariants.isNotEmpty ? _getCountsFromVariantData(_simulationVariants[_selectedSimulationIndex])['total'] : (_getCountsFromVariantData(selectedData)['total'])} Soal',
                      ),
                      const SizedBox(width: 16),
                      BoxQuizComponents(
                        label: 'Durasi',
                        text:
                            '${(_simulationVariants.isNotEmpty ? (_simulationVariants[_selectedSimulationIndex]['duration'] ?? selectedData?['duration'] ?? 100 * 60) : (selectedData?['duration'] ?? 100 * 60)) ~/ 60} Menit',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      late final Map<String, dynamic> launchData;
                      late final String simulationLabel;

                      if (_simulationVariants.isNotEmpty &&
                          _simulationVariants[_selectedSimulationIndex]
                              .isNotEmpty) {
                        final Map<String, dynamic> variant =
                            Map<String, dynamic>.from(
                              _simulationVariants[_selectedSimulationIndex],
                            );
                        if (!variant.containsKey('duration') &&
                            selectedData != null &&
                            selectedData.containsKey('duration')) {
                          variant['duration'] = selectedData['duration'];
                        }
                        launchData = variant;
                        simulationLabel =
                            'Simulasi CPNS ${_selectedSimulationIndex + 1}';
                      } else if (selectedData != null) {
                        launchData = Map<String, dynamic>.from(selectedData);
                        simulationLabel =
                            selectedData['title'] as String? ?? 'Simulasi CPNS';
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Tidak ada data simulasi yang dipilih.',
                            ),
                          ),
                        );
                        return;
                      }

                      final User? currentUser =
                          FirebaseAuth.instance.currentUser;
                      final int currentEnergy =
                          await EnergyService.getCurrentEnergy(currentUser);

                      if (currentEnergy < EnergyService.simulationCost) {
                        if (!mounted) return;
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Energy tidak cukup. Minimal ${EnergyService.simulationCost} energy untuk mulai simulasi.',
                            ),
                          ),
                        );
                        return;
                      }

                      if (!mounted) return;
                      final bool? isConfirmed = await showDialog<bool>(
                        // ignore: use_build_context_synchronously
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            title: const Text('Konfirmasi Energy'),
                            content: Text(
                              'Mulai simulasi akan memakai ${EnergyService.simulationCost} energy. Lanjut?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(false),
                                child: const Text('Batal'),
                              ),
                              ElevatedButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(true),
                                child: const Text('Lanjut'),
                              ),
                            ],
                          );
                        },
                      );

                      if (isConfirmed != true) return;

                      final bool consumed =
                          await EnergyService.consumeSimulationEnergy(
                            currentUser,
                          );

                      if (!consumed) {
                        if (!mounted) return;
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Energy tidak cukup. Minimal ${EnergyService.simulationCost} energy untuk mulai simulasi.',
                            ),
                          ),
                        );
                        return;
                      }

                      if (!mounted) return;
                      Navigator.push(
                        // ignore: use_build_context_synchronously
                        context,
                        MaterialPageRoute(
                          builder: (context) => TryOutViews(
                            data: launchData,
                            isSimulation: true,
                            simulationLabel: simulationLabel,
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
                      'Mulai Simulasi',
                      style: TextStyle(fontSize: 16, color: Color(0xFF6A5AE0)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          AdManager(
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
