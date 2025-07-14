import 'package:flutter/material.dart';

class ListComponents extends StatelessWidget {
  final String desc;

  const ListComponents({super.key, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('•', style: TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(child: Text(desc, style: TextStyle(fontSize: 14))),
      ],
    );
  }
}
