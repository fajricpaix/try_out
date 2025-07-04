import 'package:flutter/material.dart';
import 'package:try_out/views/home/content/menu.dart';
import 'package:try_out/views/home/header/header.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:try_out/widgets/ads/ads_manager.dart';
import 'package:try_out/widgets/ads/ads_constant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bank Soal CPNS',
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5E00B0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 32.0),
        child: Column(
          children: [
            SizedBox(
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
      // Gunakan AdManager untuk menampilkan banner ad
      bottomNavigationBar: AdManager(
        showBanner: true,
        bannerAdUnitId: AdsConstants.bannerAdUnitId, // Gunakan ID dari constants
      ),
    );
  }
}