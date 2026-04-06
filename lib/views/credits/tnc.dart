import 'package:flutter/material.dart';
import 'package:try_out/widgets/ads/ads_constant.dart';
import 'package:try_out/widgets/ads/ads_manager.dart';
import 'package:try_out/widgets/documents/desc.dart';
import 'package:try_out/widgets/documents/list.dart';
import 'package:try_out/widgets/documents/title.dart';

class TNCView extends StatelessWidget {
  const TNCView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Syarat & Ketentuan'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitleComponents(title: '1. Persetujuan'),
                  DescComponents(
                    desc: 'Dengan menggunakan aplikasi TES CPNS SSCASN 2025 BANK SOAL Baru & Terlengkap (selanjutnya disebut “Aplikasi”), Anda dianggap telah membaca, memahami, dan menyetujui semua syarat dan ketentuan yang berlaku.',
                  ),
                  
                  TitleComponents(title: '2. Tujuan Penggunaan'),
                  DescComponents(
                    desc: 'Aplikasi ini disediakan sebagai media pembelajaran dan latihan soal CPNS. Semua konten di dalam aplikasi ditujukan hanya untuk membantu pengguna dalam persiapan menghadapi ujian CPNS dan bukan sebagai jaminan kelulusan.',
                  ),
                  
                  TitleComponents(title: '3. Hak Kekayaan Intelektual'),
                  ListComponents(desc: 'Seluruh materi, termasuk soal, desain, ikon, dan fitur yang ada dalam Aplikasi ini adalah milik Candramawa Studio.'),
                  ListComponents(desc: 'Dilarang menggandakan, menyalin, atau mendistribusikan sebagian atau seluruh materi tanpa izin tertulis dari Candramawa Studio.'),
                  SizedBox(height: 8),

                  TitleComponents(title: '4. Privasi dan Data Pengguna'),
                  ListComponents(desc: 'Aplikasi ini tidak memerlukan pendaftaran atau login untuk digunakan.'),
                  ListComponents(desc: 'Tidak ada pengumpulan data pribadi seperti nama, email, atau nomor telepon pengguna.'),
                  ListComponents(desc: 'Aplikasi hanya menggunakan koneksi internet untuk menampilkan konten dan menggunakan Google Analytics untuk analisis umum, seperti jenis device dan sistem operasi yang digunakan.'),
                  ListComponents(desc: 'Data analitik tersebut bersifat agregat dan anonim, semata-mata untuk keperluan pengembangan dan perbaikan layanan aplikasi.'),
                  SizedBox(height: 8),

                  TitleComponents(title: '5. Batasan Tanggung Jawab'),
                  ListComponents(desc: 'TES CPNS SSCASN 2025 BANK SOAL Baru & Terlengkap tidak bertanggung jawab atas kesalahan materi atau kerugian apapun yang timbul akibat penggunaan aplikasi ini.'),
                  ListComponents(desc: 'Pengguna memahami bahwa aplikasi ini hanya sebagai sarana latihan dan pembelajaran mandiri, dan bukan penyelenggara resmi ujian CPNS.'),
                  SizedBox(height: 8),

                  TitleComponents(title: '6. Perubahan Syarat dan Ketentuan'),
                  DescComponents(desc: 'Candramawa Studio berhak mengubah, menambah, atau mengurangi syarat dan ketentuan ini sewaktu-waktu. Perubahan akan langsung berlaku setelah diunggah pada Aplikasi ini.'),
                  
                  TitleComponents(title: '7. Hukum yang Berlaku'),
                  DescComponents( desc: 'Syarat dan ketentuan ini diatur berdasarkan hukum yang berlaku di Republik Indonesia.'),
                  
                  TitleComponents(title: '8. Kontak'),
                  DescComponents(desc: 'Untuk pertanyaan, kritik, atau saran terkait Aplikasi ini, silakan hubungi: 📧 candramawa.std@gmail.com'),
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
