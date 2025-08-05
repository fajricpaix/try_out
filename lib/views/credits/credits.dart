import 'package:flutter/material.dart';
import 'package:try_out/views/credits/tnc.dart';
import 'package:try_out/widgets/ads/ads_constant.dart';
import 'package:try_out/widgets/ads/ads_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class CreditsView extends StatelessWidget {
  const CreditsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Info', style: TextStyle(color: Color(0xFF6A5AE0))),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFF6A5AE0),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TNCView()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Syarat & Ketentuan',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
                ],
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Konfirmasi"),
                  backgroundColor: Colors.white,
                  content: const Text(
                    "Anda akan diarahkan ke browser untuk memberikan review?"),
                  actions: [
                  TextButton(
                    child: const Text("Batal"),
                    onPressed: () {
                    Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text("Lanjutkan"),
                    onPressed: () {
                    Navigator.of(context).pop();
                    final Uri url =
                      Uri.parse('https://www.candramawa.space');
                    Future<void> launchUrlBrowser() async {
                      if (!await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                      )) {
                      throw Exception('Could not launch $url');
                      }
                    }

                    launchUrlBrowser();
                    },
                  ),
                  ],
                );
                },
              );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Give Us a Review',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AdManager(
        showBanner: true,
        bannerAdUnitId:
            AdsConstants.bannerAdUnitId, // Gunakan ID dari constants
      ),
    );
  }
}
