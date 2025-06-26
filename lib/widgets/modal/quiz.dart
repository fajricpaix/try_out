import 'package:flutter/material.dart';

class QuizModal extends StatelessWidget {
  final int totalQuestions;
  final int currentIndex;
  final List<Map<String, dynamic>>? userAnswers;
  final Function(int) onSelectQuestion; // This callback now receives the selected index

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
      title: const Text('Nomor Soal'),
      content: SizedBox(
        width: double.maxFinite,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: totalQuestions,
          itemBuilder: (context, index) {
            final overallQuestionIndex = index; // 0-based index
            final isAnswered = _isQuestionAnswered(overallQuestionIndex);
            final isCurrentQuestion = overallQuestionIndex == currentIndex;

            Color backgroundColor;
            Color textColor;

            if (isCurrentQuestion) {
              backgroundColor = Color(0xFF6A5AE0); // Highlight current question
              textColor = Colors.white;
            } else if (isAnswered) {
              backgroundColor = Colors.green; // Saved answer color
              textColor = Colors.white;
            } else {
              backgroundColor = Colors.grey.shade200; // Default color
              textColor = Colors.black;
            }

            return GestureDetector(
              onTap: () {
                // When a number is tapped, call the onSelectQuestion callback
                // which will then pop the dialog and handle navigation in the parent.
                onSelectQuestion(overallQuestionIndex);
                // No need to pop here, as the parent will do it.
                // Navigator.of(context).pop(); // REMOVE THIS LINE IF IT WAS HERE
              },
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}', // Display 1-based number
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
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
            Navigator.of(context).pop(); // This closes the dialog without selecting a number
          },
          child: const Text('Tutup'),
        ),
      ],
    );
  }
}