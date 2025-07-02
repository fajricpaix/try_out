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
          // Filter out nulls and ensure items are Maps
          // The .toList() creates a new List of the filtered items
          return rawValue.where((e) => e != null && e is Map).toList();
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

          // Helper function to safely get a property from a package at a given index
          String getSafeProperty(int index, String property, String defaultValue) {
            if (index < cpnsData.length && cpnsData[index] is Map) {
              final Map<String, dynamic> packageMap = Map<String, dynamic>.from(cpnsData[index] as Map);
              return packageMap[property] as String? ?? defaultValue;
            }
            return defaultValue;
          }

          final String easyLevel = getSafeProperty(0, 'level', 'Mudah');
          final String mediumLevel = getSafeProperty(1, 'level', 'Sedang');
          final String hardLevel = getSafeProperty(2, 'level', 'Susah');


          return SingleChildScrollView(
            child: Column(
              children: [
                ThumbnailTraining(
                  imagePath: 'assets/training/latihan_1.webp',
                  title: 'Paket 1 : Pemanasan Awal',
                  description: 'Langkah Kecil Menuju Sukses',
                  isColorTop: Colors.white,
                  isColor: const Color(0xFF8376E5),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DashboardQuetionView(
                          level: easyLevel,
                        ),
                      ),
                    );
                  },
                ),
                ThumbnailTraining(
                  imagePath: 'assets/training/latihan_2.webp',
                  title: 'Paket 2: Tantangan Lanjutan',
                  description: 'Uji Kemampuan & Tambah Percaya Diri',
                  isColorTop: const Color(0xFF8376E5),
                  isColor: const Color(0xFF604FDE),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DashboardQuetionView(
                          level: mediumLevel,
                        ),
                      ),
                    );
                  },
                ),
                ThumbnailTraining(
                  imagePath: 'assets/training/latihan_3.webp',
                  title: 'Paket 3: Latihan Soal Terbaru',
                  description: 'Belajar soal-soal terbaru',
                  isColorTop: const Color(0xFF604FDE),
                  isColor: const Color(0xFF301FA7),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DashboardQuetionView(
                          level: hardLevel,
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