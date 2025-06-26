import 'package:flutter/material.dart';

class QuizModal extends StatelessWidget {
  final int totalQuestions;
  final int currentIndex;
  final List<Map<String, dynamic>>? userAnswers;
  final Function(int) onSelectQuestion;

  const QuizModal({
    super.key,
    required this.totalQuestions,
    required this.currentIndex,
    this.userAnswers,
    required this.onSelectQuestion,
  });

  // Helper to check if a question has been answered
  bool _isQuestionAnswered(int overallIndex) {
    return (userAnswers ?? []).any((answer) => answer['overallIndex'] == overallIndex);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Nomor Soal', 
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600
        )),
      content: SizedBox(
        width: double.maxFinite,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: totalQuestions,
          itemBuilder: (context, index) {
            final overallQuestionIndex = index;
            final isAnswered = _isQuestionAnswered(overallQuestionIndex);
            final isCurrentQuestion = overallQuestionIndex == currentIndex;

            Color backgroundColor;
            Color textColor;

            if (isCurrentQuestion) {
              backgroundColor = Color(0xFF6A5AE0); // Highlight current question
              textColor = Colors.white;
            } else if (isAnswered) {
              backgroundColor = Colors.blueAccent; // Saved answer color
              textColor = Colors.white;
            } else {
              backgroundColor = Colors.grey.shade200; // Default color
              textColor = Colors.black;
            }

            return GestureDetector(
              onTap: () {
                onSelectQuestion(overallQuestionIndex);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: textColor,
                  ),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Tutup'),
        ),
      ],
    );
  }
}