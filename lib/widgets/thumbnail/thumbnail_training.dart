import 'package:flutter/material.dart';

class ThumbnailTraining extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final Color isColorTop;
  final Color isColor;
  final Widget trainingPage;


  const ThumbnailTraining({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.isColorTop,
    required this.isColor,
    required this.trainingPage, 
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isColor,
        padding: const EdgeInsets.only(bottom: 8, top: 0),
        // minimumSize: const Size.fromHeight(180),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        elevation: 0,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => trainingPage),
        );
      },
      child: Column(
        children: [
          Container(
            height: 16,
            decoration: BoxDecoration(
              color: isColorTop,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(22)),
            ),
          ),
          Row(
            children: [
              Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      ),
                    ),
                  ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Image.asset(imagePath, height: 130, fit: BoxFit.cover),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
