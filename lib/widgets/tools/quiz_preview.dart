import 'package:flutter/material.dart';
import 'package:try_out/views/quetions/quiz.dart';
import 'package:try_out/widgets/tools/box_quiz.dart';

class QuizPreviewTabContent extends StatelessWidget {
  final String title;
  final String desc;
  final String level;
  final List quizList;

  const QuizPreviewTabContent({
    super.key,
    required this.title,
    required this.desc,
    required this.level,
    required this.quizList,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
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
                  'Latihan Soal',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6A5AE0)),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(desc),
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
                  text: '${quizList.length}',
                ),
                const SizedBox(width: 16),
                BoxQuizComponents(label: 'Tingkat Kesulitan', text: level),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizView(quizData: quizList),
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
                style: TextStyle(fontSize: 16, color: Color(0xFF6A5AE0)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
