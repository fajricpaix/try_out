import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Keluar dari Latihan?'),
      content: const Text('Apakah kamu yakin ingin keluar dari latihan soal ini?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Batal', style: TextStyle(color: Color(0xFF6A5AE0))),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Keluar', style: TextStyle(color: Colors.red)),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }
}