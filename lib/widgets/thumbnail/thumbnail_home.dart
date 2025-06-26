import 'package:flutter/material.dart';

class ThumbnailHome extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final bool isDarkText;
  final String isBackground;
  final Widget menuPage;

  const ThumbnailHome({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    this.isDarkText = true,
    required this.isBackground,
    required this.menuPage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 110,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                isBackground,
              ), // or NetworkImage
              fit: BoxFit.none,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 8),
            minimumSize: const Size.fromHeight(110),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => menuPage),
            );
          },
          child: Row(
            children: [
              Image.asset(imagePath, width: 60, fit: BoxFit.cover),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkText ? Colors.black : Colors.white,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDarkText ? Colors.black : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(
                  Icons.arrow_forward,
                  size: 32,
                  color: isDarkText ? Colors.black : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
