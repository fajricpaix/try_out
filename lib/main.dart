import 'package:flutter/material.dart';
import 'package:try_out/views/home/home_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CPNS Try Out 2025',
      theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      ),
      home: HomeView(),
    );
  }
}
