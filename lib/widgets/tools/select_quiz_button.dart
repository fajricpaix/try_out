import 'package:flutter/material.dart';

class SelectQuizButton extends StatelessWidget {
  final String text;
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  // New props
  final bool isCorrect;
  final bool isWrong;
  final bool showResult;

  const SelectQuizButton({
    required this.text,
    required this.label,
    required this.isSelected,
    required this.onPressed,
    this.isCorrect = false,
    this.isWrong = false,
    this.showResult = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = const Color(0xFFEFF1FE);
    Color textColor = const Color(0xFF6A5AE0);
    Color borderColor = Colors.transparent;

    if (showResult) {
      if (isCorrect) {
        backgroundColor = Colors.green[100]!;
        borderColor = Colors.green;
      } else if (isWrong) {
        backgroundColor = Colors.red[100]!;
        borderColor = Colors.red;
      }
    } else if (isSelected) {
      backgroundColor = const Color(0xFF6A5AE0);
      textColor = Colors.white;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Text(
            '$label.',
            style: TextStyle(
              color: Color(0xFF604FDE),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: backgroundColor,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: borderColor, width: 2),
                ),
              ),
              onPressed: onPressed,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(text, style: TextStyle(color: textColor)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
