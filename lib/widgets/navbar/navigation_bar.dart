import 'package:flutter/material.dart';

class NavigationBar extends StatelessWidget {
  final String title;
  const NavigationBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return 
      Scaffold(
        appBar: AppBar(
        title: const Text('PDF Viewer'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        margin: const EdgeInsets.only(top: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white, width: 1.0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      )
    );
  }
}
