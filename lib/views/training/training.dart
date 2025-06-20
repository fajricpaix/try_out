import 'package:flutter/material.dart';
import 'package:try_out/views/quetions/dashboard.dart';
import 'package:try_out/widgets/thumbnail/thumbnail_training.dart';

class TrainingView extends StatelessWidget {
  const TrainingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Latihan Soal', style: TextStyle(color: Color(0xFF6A5AE0), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF6A5AE0)),
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(22),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ThumbnailTraining(
              isColorTop: Colors.white,
              isColor: const Color(0xFF8376E5),
              imagePath: 'assets/training/latihan_1.webp',
              title: 'Paket 1 : Pemanasan Awal',
              description: 'Langkah Kecil Menuju Sukses',
              trainingPage: const DashboardQuetionView(),
            ),
            ThumbnailTraining(
              isColorTop: const Color(0xFF8376E5),
              isColor: const Color(0xFF604FDE),
              imagePath: 'assets/training/latihan_2.webp',
              title: 'Paket 2: Tantangan Lanjutan',
              description: 'Uji Kemampuan & Tambah Percaya Diri',
              trainingPage: const DashboardQuetionView(),
            ),
            ThumbnailTraining(
              isColorTop: const Color(0xFF604FDE),
              isColor: const Color(0xFF301FA7),
              imagePath: 'assets/training/latihan_3.webp',
              title: 'Paket 3: Latihan Soal Terbaru',
              description: 'Belajar soal-soal terbaru',
              trainingPage: const DashboardQuetionView(),
            ),
            Container(
            height: 16,
            decoration: BoxDecoration(
              color: const Color(0xFF301FA7),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(22)),
            ),
          ),
          ]
        ),
      ),
    );
  }
}
