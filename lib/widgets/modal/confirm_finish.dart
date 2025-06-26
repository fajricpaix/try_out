// widgets/modal/confirmation_dialog.dart
import 'package:flutter/material.dart';

class ConfirmationFinish extends StatelessWidget {
  final String title;
  final String content;
  final String confirmButtonText;
  final String cancelButtonText;

  const ConfirmationFinish({
    super.key,
    this.title = 'Konfirmasi',
    this.content = 'Apakah Anda yakin?',
    this.confirmButtonText = 'Ya',
    this.cancelButtonText = 'Tidak',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false), // User chose not to confirm
          child: Text(cancelButtonText),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true), // User confirmed
          child: Text(confirmButtonText),
        ),
      ],
    );
  }
}