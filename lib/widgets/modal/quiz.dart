import 'package:flutter/material.dart';

class QuizModal extends StatelessWidget {
  final int totalQuestions;
  final int currentIndex;
  final Function(int) onSelectQuestion;

  const QuizModal({
    super.key,
    required this.onSelectQuestion,
    required this.currentIndex,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        'Pilih Soal (1 - $totalQuestions)',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 1.25,
          ),
          itemCount: totalQuestions,
          itemBuilder: (context, index) {
            final bool isCurrent = index == currentIndex;
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: isCurrent ? Color(0xFF6A5AE0) : const Color(0xFFEFF1FE),
                padding: const EdgeInsets.all(4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                onSelectQuestion(index);
              },
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: isCurrent ? Colors.white : const Color(0xFF6A5AE0),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Tutup',
            style: TextStyle(
              color: Colors.red
            ),
          ),
        ),
      ],
    );
  }
}
