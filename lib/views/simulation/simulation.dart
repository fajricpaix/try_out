import 'package:firebase_database/firebase_database.dart'; // Firebase Realtime Database
import 'package:flutter/material.dart';
import 'package:try_out/views/tryout/try_out.dart'; // Ensure this path is correct for TryOutViews
import 'package:try_out/widgets/ads/ads_constant.dart';
import 'package:try_out/widgets/ads/ads_manager.dart';
import 'package:try_out/widgets/tools/box_quiz.dart'; // Ensure this path is correct for BoxQuizComponents

class SimulationView extends StatefulWidget {
  const SimulationView({super.key});

  @override
  State<SimulationView> createState() => _SimulationViewState();
}

class _SimulationViewState extends State<SimulationView> {
  Map<String, dynamic> data = {};
  String? selectedKey;
  bool _isLoading = true; // Added loading state

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
              final Map<String, dynamic> packageData = Map<String, dynamic>.from(item);

              if (packageData.containsKey('type') && packageData['type'] == 'simulasi') {
                final String generatedKey = 'simulasi_${packageCounter++}';
                filteredData[generatedKey] = packageData;
              }
            }
          }
        } else if (snapshot.value is Map) {
          (snapshot.value as Map<dynamic, dynamic>).forEach((key, value) {
            if (value is Map) {
              final Map<String, dynamic> packageData = Map<String, dynamic>.from(value);
              if (packageData.containsKey('type') && packageData['type'] == 'simulasi') {
                filteredData[key.toString()] = packageData;
              }
            }
          });
        }
      }

      setState(() {
        data = filteredData;
        selectedKey = data.keys.isNotEmpty ? data.keys.first : null;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data from Firebase: $e');
      setState(() {
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

    int jumlahSoal = 0;
    if (selectedData != null) {
      var categories = selectedData['category'];
      if (categories is List) {
        for (var cat in categories) {
          if (cat is Map) {
            final Map<String, dynamic> categoryMap = Map<String, dynamic>.from(cat);
            if (categoryMap.containsKey('quiz') && categoryMap['quiz'] is List) {
              jumlahSoal += (categoryMap['quiz'] as List).length;
            }
          }
        }
      } else if (categories is Map) {
        categories.forEach((key, value) {
          if (value is Map) {
            final Map<String, dynamic> categoryMap = Map<String, dynamic>.from(value);
            if (categoryMap.containsKey('quiz') && categoryMap['quiz'] is List) {
              jumlahSoal += (categoryMap['quiz'] as List).length;
            }
          }
        });
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
      body: Stack( // Use Stack to place the AdManager without affecting the main layout
        children: [
          // Your existing Column containing all the UI elements
          Column(
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
                    final level = entry.value['level'] ?? 'Unknown Level';
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
                      'Simulasi Soal',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6A5AE0)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selectedData['title'] ?? 'Judul Tidak Tersedia',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(selectedData['desc'] ?? 'Deskripsi Tidak Tersedia'),
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
                      text: selectedData.containsKey('duration') ? '${(selectedData['duration'] / 60).round()} Menit' : 'N/A',
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
                      text: '${selectedData['passing_grade'] ?? 'N/A'}/1000',
                    ),
                    const SizedBox(width: 16),
                    BoxQuizComponents(
                      label: 'Tingkat Kesulitan',
                      text: selectedData['level'] ?? 'N/A',
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
                    'Mulai Simulasi',
                    style: TextStyle(fontSize: 16, color: Color(0xFF6A5AE0)),
                  ),
                ),
              ),
            ],
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