import 'package:flutter/material.dart';

class DescComponents extends StatelessWidget {
  final String desc;

  const DescComponents({super.key, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          desc,
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
