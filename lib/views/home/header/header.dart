import 'package:flutter/material.dart';
import 'package:try_out/views/home/header/slide_header.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return 
      Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'AYO BERGABUNG MENJADI ASN',
                  style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  ),
                ),
                Text(
                  'BERKARYA UNTUK TANAH AIR, BERSAMA MEWUJUDKAN INDONESIA MAJU',
                  style: TextStyle(
                  color: const Color(0xFFFFD600),
                  fontSize: 14,
                  fontWeight: FontWeight.w600
                  ),
                ),
                SizedBox(height: 16),
                SlideHeader()
              ],
            ),
          )
        ],
      );
  }
}
