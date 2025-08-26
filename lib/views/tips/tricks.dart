import 'package:flutter/material.dart';
import 'dart:async';
import 'package:try_out/widgets/ads/ads_constant.dart';
import 'package:try_out/widgets/ads/ads_manager.dart';

class TricksView extends StatefulWidget {
  const TricksView({super.key});

  @override
  State<TricksView> createState() => _TricksViewState();
}

class _TricksViewState extends State<TricksView> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _timer;
  Timer? _loadingTimer;
  double _loadingProgress = 0.0;

  // Sample data for 5 slides - replace with your actual content
  final List<Map<String, dynamic>> _slides = [
    {'imgUrl': 'assets/donts/donts-1.webp'},
    {'imgUrl': 'assets/donts/donts-2.webp'},
    {'imgUrl': 'assets/donts/donts-3.webp'},
    {'imgUrl': 'assets/donts/donts-4.webp'},
    {'imgUrl': 'assets/donts/donts-5.webp'},
  ];

  @override
  void initState() {
    super.initState();
    _startLoadingAnimation();
    _startAutoScroll();
  }

  void _startLoadingAnimation() {
    _loadingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          _loadingProgress += 0.0125; // 8000ms / 100ms = 80 steps, 1/80 = 0.0125
          if (_loadingProgress >= 1.0) {
            _loadingProgress = 1.0;
            _loadingTimer?.cancel();
          }
        });
      }
    });
  }

  void _resetLoadingForNextSlide() {
    _loadingProgress = 0.0;
    _loadingTimer?.cancel();
    
    // Mulai loading animation untuk semua slide (termasuk slide terakhir)
    _startLoadingAnimation();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (_pageController.hasClients && mounted) {
        // Jangan lanjut jika sudah di slide terakhir
        if (_currentIndex < _slides.length - 1) {
          int nextIndex = _currentIndex + 1;
          
          _pageController.animateToPage(
            nextIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          // Hentikan auto scroll jika sudah di slide terakhir, tapi tetap jalankan loading
          _timer?.cancel();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _loadingTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Do`s & Don`t',
          style: TextStyle(color: Color(0xFFFC7E37), fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFFFC7E37)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            // Dot Indicators dengan Loading Bar Effect
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 6,
                  width: (MediaQuery.of(context).size.width / 5) - 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD8C3), // Background color
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Stack(
                    children: [
                      // Loading bar effect
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.linear,
                        height: 6,
                        width: _getLoadingWidth(index),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFC7E37), // Active color
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Story Slider Container
            Container(
              height: MediaQuery.of(context).size.height - 241,
              margin: const EdgeInsets.only(top: 24),
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                  _resetLoadingForNextSlide();
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Image.asset(
                          _slides[index]['imgUrl'],
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Gunakan AdManager untuk menampilkan banner ad
      bottomNavigationBar: AdManager(
        showBanner: true,
        bannerAdUnitId:
            AdsConstants.bannerAdUnitId, // Gunakan ID dari constants
      ),
    );
  }

  double _getLoadingWidth(int index) {
    double fullWidth = (MediaQuery.of(context).size.width / 5) - 14;
    
    if (index < _currentIndex) {
      // Slide yang sudah selesai - full width
      return fullWidth;
    } else if (index == _currentIndex) {
      // Slide yang sedang aktif - loading progress
      return fullWidth * _loadingProgress;
    } else {
      // Slide yang belum aktif - width 0
      return 0;
    }
  }
}