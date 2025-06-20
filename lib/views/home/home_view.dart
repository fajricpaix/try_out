import 'package:flutter/material.dart';
import 'package:try_out/views/home/content/menu.dart';
import 'package:try_out/views/home/header/header.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5E00B0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 32.0),
        child: 
          Column(
            children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Header(),
                  MenuContent(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}