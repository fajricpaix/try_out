import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:try_out/views/quetions/dashboard.dart';
import 'package:try_out/widgets/thumbnail/thumbnail_training.dart';

class TrainingView extends StatelessWidget {
  const TrainingView({super.key});

  Future<Map<String, dynamic>> loadSoalData() async {
    final jsonString = await rootBundle.loadString('assets/json/try_out.json');
    final Map<String, dynamic> decodedData = json.decode(jsonString);
    return decodedData['cpns'] ?? {};
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: loadSoalData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          final easyLevel = data['level'] ?? 'Mudah';
          final mediumLevel = data['level'] ?? 'Sedang';
          final hardLevel = data['level'] ?? 'Susah';

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