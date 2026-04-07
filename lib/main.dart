import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:try_out/views/home/content/menu.dart';
import 'package:try_out/views/home/header/header.dart';
import 'package:try_out/views/auth/auth_page.dart';
import 'package:try_out/views/auth/profile_page.dart';
import 'package:try_out/widgets/ads/ads_constant.dart';
import 'package:try_out/widgets/ads/ads_manager.dart';

import 'firebase_options.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  MobileAds.instance.initialize();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAuth.instance.setLanguageCode('id');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Bank Soal CPNS', home: const SplashPage());
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const MyHomePage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF5E00B0),
      body: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(26)),
            boxShadow: [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 24,
                spreadRadius: 2,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(26)),
            child: Image(
              image: AssetImage('assets/icon/app_icon.png'),
              width: 132,
              height: 132,
            ),
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> _openAccountPage(User? user) async {
    if (user == null) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AuthPage()),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProfilePage(user: user)),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        final User? currentUser = snapshot.data;
        const double stickyTopBarHeight = 56;

        return Scaffold(
          backgroundColor: const Color(0xFF5E00B0),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(top: 88),
                child: Column(
                  children: [
                    const Header(),
                    MenuContent(),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(bottom: 16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          // topLeft: Radius.circular(36),
                          topRight: Radius.circular(36),
                        ),
                      ),
                      child: AdManager(
                        showBanner: true,
                        bannerAdUnitId: AdsConstants.bannerAdUnitId,
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                bottom: false,
                child: SizedBox(
                  height: stickyTopBarHeight,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF5E00B0).withValues(alpha: 0.2),
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                        ),
                        child: HeaderTopBar(
                          user: currentUser,
                          onAccountPressed: () => _openAccountPage(currentUser),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
