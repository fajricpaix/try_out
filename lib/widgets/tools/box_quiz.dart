import 'package:flutter/material.dart';

class BoxQuizComponents extends StatelessWidget {
  final String label;
  final String text;
  
  const BoxQuizComponents({
    super.key, 
    required this.label,
    required this.text, 
    });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 14)),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
      ),
    );
  }
}
