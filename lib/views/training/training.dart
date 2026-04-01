import 'package:flutter/material.dart';
import 'package:try_out/views/quetions/dashboard.dart';
import 'package:try_out/widgets/thumbnail/thumbnail_training.dart';
import 'package:firebase_database/firebase_database.dart'; // Import Firebase Database

class TrainingView extends StatelessWidget {
  const TrainingView({super.key});

  Future<List<dynamic>> loadSoalData() async {
    try {
      final DatabaseReference cpnsRef = FirebaseDatabase.instance.ref('cpns');
      final DataSnapshot snapshot = await cpnsRef.get();

      if (snapshot.exists && snapshot.value != null) {
        final dynamic rawValue = snapshot.value;
        if (rawValue is List) {
          // Keep only valid map-like rows from RTDB list payloads.
          return rawValue.where((e) => e != null && e is Map).toList();
        } else if (rawValue is Map) {
          // RTDB indexed children can arrive as Map<String, dynamic>.
          return rawValue.values.where((e) => e is Map).toList();
        } else {
          debugPrint("Firebase node 'cpns' is not a List. It's a ${rawValue.runtimeType}.");
          return []; // Return empty list if format is incorrect
        }
      } else {
        debugPrint("Firebase snapshot does not exist or value is null at 'cpns'.");
        return []; // Return empty list if no data
      }
    } catch (e) {
      debugPrint('Error loading data from Firebase: $e');
      return Future.error('Failed to load training data: $e'); // Propagate error for FutureBuilder
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Latihan Soal',
          style: TextStyle(
            color: Color(0xFF6A5AE0),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF6A5AE0)),
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(22),
          ),
        ),
        titleSpacing: 0,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: loadSoalData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading data: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No training data found.'));
          }

          final List<dynamic> cpnsData = snapshot.data!;

          // Find row that owns the category key (twk, tiu, tkp).
          Map<String, dynamic>? findRowByCategoryKey(String key) {
            for (final item in cpnsData) {
              if (item is Map && item.containsKey(key)) {
                return Map<String, dynamic>.from(item);
              }
            }
            return null;
          }

          final twkItem = findRowByCategoryKey('twk');
          final tiuItem = findRowByCategoryKey('tiu');
          final tkpItem = findRowByCategoryKey('tkp');

          return SingleChildScrollView(
            child: Column(
              children: [
                ThumbnailTraining(
                  imagePath: 'assets/training/latihan_1.webp',
                  title: twkItem?['title'] as String? ?? 'TWK : Pemanasan Awal',
                  description: twkItem?['desc'] as String? ?? 'Langkah Kecil Menuju Sukses',
                  isColorTop: Colors.white,
                  isColor: const Color(0xFF8376E5),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DashboardQuetionView(
                          initialPackage: {
                            'title': twkItem?['title'],
                            'desc': twkItem?['desc'],
                            'twk': twkItem?['twk'],
                          },
                          initialCategory: 'twk',
                          level: twkItem?['title'] as String?,
                        ),
                      ),
                    );
                  },
                ),
                ThumbnailTraining(
                  imagePath: 'assets/training/latihan_2.webp',
                  title: tiuItem?['title'] as String? ?? 'TIU: Tantangan Pengetahuan Umum',
                  description: tiuItem?['desc'] as String? ?? 'Uji Kemampuan & Tambah Percaya Diri',
                  isColorTop: const Color(0xFF8376E5),
                  isColor: const Color(0xFF604FDE),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DashboardQuetionView(
                          initialPackage: {
                            'title': tiuItem?['title'],
                            'desc': tiuItem?['desc'],
                            'tiu': tiuItem?['tiu'],
                          },
                          initialCategory: 'tiu',
                          level: tiuItem?['title'] as String?,
                        ),
                      ),
                    );
                  },
                ),
                ThumbnailTraining(
                  imagePath: 'assets/training/latihan_3.webp',
                  title: tkpItem?['title'] as String? ?? 'TKP: Latihan Menilai Integrasi Diri',
                  description: tkpItem?['desc'] as String? ?? 'Belajar soal-soal terbaru',
                  isColorTop: const Color(0xFF604FDE),
                  isColor: const Color(0xFF301FA7),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DashboardQuetionView(
                          initialPackage: {
                            'title': tkpItem?['title'],
                            'desc': tkpItem?['desc'],
                            'tkp': tkpItem?['tkp'],
                          },
                          initialCategory: 'tkp',
                          level: tkpItem?['title'] as String?,
                        ),
                      ),
                    );
                  },
                ),
                Container(
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Color(0xFF301FA7),
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(22)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}