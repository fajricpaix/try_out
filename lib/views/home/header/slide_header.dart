import 'package:flutter/material.dart';
import 'package:try_out/views/tips/documents.dart';
import 'package:try_out/views/tips/tricks.dart';

class SlideHeader extends StatefulWidget {
  const SlideHeader({super.key});

  @override
  State<SlideHeader> createState() => _SlideHeaderState();
}

class _SlideHeaderState extends State<SlideHeader> {
  final PageController _pageController = PageController();
  final List<String> imageUrls = [
    'assets/slides/slide_1.webp',
    'assets/slides/slide_2.webp',
  ];
  final List<Widget> views = [
    const DocumentsView(),
    const TricksView(),
  ];

  @override
  void initState() {
    super.initState();
    // Auto slide every 3 seconds
    Future.delayed(Duration.zero, () {
      autoSlide();
    });
  }

  void autoSlide() {
    Future.delayed(const Duration(seconds: 5), () {
      if (_pageController.hasClients) {
        if (_pageController.page == imageUrls.length - 1) {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
        autoSlide();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1136 / 664,
      child: PageView.builder(
        controller: _pageController,
        itemCount: null, // Set to null for infinite scrolling
        itemBuilder: (context, index) {
          final adjustedIndex = index % imageUrls.length;
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => views[adjustedIndex]));
            },
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(imageUrls[adjustedIndex]),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
