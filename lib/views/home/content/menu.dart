import 'package:flutter/material.dart';
import 'package:try_out/views/training/training.dart';
import 'package:try_out/widgets/thumbnail/thumbnail_home.dart';

class MenuContent extends StatelessWidget {
  const MenuContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
      ),
      height: MediaQuery.of(context).size.height - 350,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 32),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Menu',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        ThumbnailHome(
          menuPage: const TrainingView(),
          imagePath: 'assets/menus/training.webp',
          title: 'Latihan Soal',
          description: 'Banyak-banyakin latihan soal biar kamu auto lulus 🎉!',
          isColor: Color(0xFFFFE500),
          isDarkText: true,
        ),
        const SizedBox(height: 20),
        
        // Simulation Card
        ThumbnailHome(
          menuPage: const SizedBox(),
          imagePath: 'assets/menus/simulation.webp',
          title: 'Simulasi',
          description: 'Biar tau sejauh mana kamu siap bertarung dengan soal-soal 🔥🔥',
          isColor: Color(0xFF5E00B0),
          isDarkText: false,
        ),
        const SizedBox(height: 20),
        
        // Credit & Support Card
        ThumbnailHome(
          menuPage: const SizedBox(),
          imagePath: 'assets/menus/credits.webp',
          title: 'Credit & Support',
          description: 'Liat siapa aja yang buat ini. Jangan lupa traktir kopi ya 😍!',
          isColor: Color(0xFF301FA7),
          isDarkText: false,
        ),

        ],
      ),
    );
  }
}
