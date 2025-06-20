import 'package:flutter/material.dart';
import 'package:try_out/views/tips/read/read.dart';
import 'package:try_out/widgets/documents/tutorial.dart';

class DocumentsView extends StatelessWidget {
  const DocumentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5E00B0),
      appBar: AppBar(
        title: const Text('Buku Petunjuk', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF5E00B0),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.white,
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Text(
                        'Tutorial Buku Petunjuk',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // List of documents
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        TutorialContent(
                          title: 'Buku Pendaftaran PPPK Guru - Sistem Seleksi CASN 2024',
                          newPage: const ReadTipsScreen(),
                        ),
                        const SizedBox(height: 16),
                        TutorialContent(
                          title: 'Buku Pendaftaran PPPK NAKES - Sistem Seleksi CASN 2024',
                          newPage: const ReadTipsScreen(),
                        ),
                        const SizedBox(height: 16),
                        TutorialContent(
                          title: 'Buku Pendaftaran PPPK Teknis - Sistem Seleksi CASN 2024 V2',
                          newPage: const SizedBox(),
                        ),
                        const SizedBox(height: 16),
                        TutorialContent(
                          title: 'Buku Petunjuk DRH 2024',
                          newPage: const SizedBox(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
