import 'package:flutter/material.dart';
import 'package:try_out/widgets/ads/ads_constant.dart';
import 'package:try_out/widgets/ads/ads_manager.dart';
import 'package:try_out/widgets/documents/desc.dart';
import 'package:try_out/widgets/documents/title.dart';

class TricksView extends StatelessWidget {
  const TricksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFC7E37),
      appBar: AppBar(
        title: const Text('Tips & Trik', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFFC7E37),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(color: Colors.white, height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Text(
                  '10 Tips Lolos CPNS 2024 yang Bisa Kamu Praktikkan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            Container(
              width: double.infinity,
              margin: EdgeInsets.only(left: 16, right: 16, bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DescComponents(
                      desc:
                          'CPNS 2024 sebentar lagi dibuka. Bagaimana nih taktik kamu untuk bisa lolos CPNS di tahun ini? Untuk bisa lolos CPNS, kamu juga harus punya taktik sendiri mengingat kamu akan bersaing dengan jutaan orang dari seluruh Indonesia. Jika kamu butuh tips lolos CPNS 2024, coba baca di bawah ini!',
                    ),
                    TitleComponents(title: 'Tips Lolos CPNS 2024'),
                    DescComponents(
                      desc:
                          'Sudah bukan rahasia lagi, setiap tahun pasti pendaftaran CPNS selalu dibanjiri oleh peserta. Nah, kalau sudah begitu, tentu kamu harus punya cara ampuh yang membuat kamu bisa lolos CPNS. Berikut ini tips lolos CPNS yang bisa kamu terapkan.',
                    ),
                    TitleComponents(title: '1. Rencanakan jadwal belajarmu'),
                    DescComponents(
                      desc:
                          'Tips lolos CPNS yang pertama adalah merencanakan jadwal belajar untuk bisa mengasah soal-soal ujian SKD. Luangkanlah waktu belajar secara intensif untuk berlatih soal, mempelajari kisi-kisi, dan membaca berbagai materi.',
                    ),
                    TitleComponents(title: '2. Rajin latihan soal-soal tes'),
                    DescComponents(
                      desc:
                          'Seperti kata pepatah “practice makes perfect”. Nah begitu juga saat kamu ingin lolos seleksi CPNS di tahun ini. Rajinlah melatih diri dengan mengerjakan soal-soal tes untuk mempersiapkan diri dari jauh-jauh hari.',
                    ),
                    DescComponents(
                      desc:
                          'Seperti yang kita tahu, di CPNS kamu akan dua kali melalui tes, pertama tes SKD (Seleksi Kemampuan Dasar) dan SKB (Seleksi Kemampuan Bidang).',
                    ),
                    DescComponents(
                      desc:
                          'Sekarang, tidak sulit buat menemukan contoh soal CPNS. Kamu bisa berlatih soal-soal CPNS, bisa melalui soal yang kamu temukan di internet, melalui buku soal, atau juga aplikasi yang menyediakan soal CPNS.',
                    ),
                    TitleComponents(
                      title:
                          '3. Mengenali dan mempelajari kisi-kisi dan materi CPNS',
                    ),
                    DescComponents(
                      desc:
                          'Jangan sampai kamu mengabaikan hal yang satu ini dari tips lolos CPNS! Cobalah untuk mencari tahu seperti apa kisis-kisi dan materi CPNS di tahun lalu.',
                    ),
                    DescComponents(
                      desc:
                          'Kamu bisa menemukan kisi-kisi tersebut dalam buku atau juga aplikasi yang dapat menjadi pedoman untuk belajar tes CPNS.',
                    ),
                    TitleComponents(
                      title: '4. Ikut kelompok belajar atau bimbel',
                    ),
                    DescComponents(
                      desc:
                          'Belajar sendiri buat beberapa orang kadang terasa berat dan cepat membuat ngantuk. Apa kamu termasuk tipe seperti itu?',
                    ),
                    DescComponents(
                      desc:
                          'Nah, kamu bisa mengatasi masalah belajar kamu dengan membentuk kelompok belajar bersama teman-teman, atau juga ikut bimbel CPNS baik tatap muka atau juga kelas online.',
                    ),
                    TitleComponents(
                      title: '5. Selalu update informasi mengenai CPNS',
                    ),
                    DescComponents(
                      desc:
                          'Hal penting berikutnya adalah pastikan kamu selalu mengikuti informasi terbaru mengenai CPNS. Kamu bisa mengikuti info di media sosial atau blog KitaLulus.',
                    ),
                    DescComponents(
                      desc:
                          'Sebab, bukan tidak mungkin ada perubahan ketentuan maupun tanggal. Atau juga bisa jadi BKN memberikan kisi-kisi mengenai tes seleksi.',
                    ),
                    TitleComponents(
                      title: '6. Persiapkan dokumen yang diperlukan',
                    ),
                    DescComponents(
                      desc:
                          'Mengingat kelengkapan dokumen merupakan syarat mutlak, tips lolos CPNS 2023 ini tak boleh kamu lewatkan.',
                    ),
                    DescComponents(
                      desc:
                          'Pastikan kamu sudah menyiapkan seluruh kebutuhan dokumen untuk pendaftaran dengan lengkap. Jangan lupa, pastikan lagi apakah semua dokumen tersebut valid dan tepat sesuai persyaratan yang ditetapkan oleh instansi dan formasi yang dibuka.',
                    ),
                    TitleComponents(title: '7. Memperhatikan passing grade'),
                    DescComponents(
                      desc:
                          'Tidak ada salahnya juga kamu memperhatikan passing grade, agar tidak gagal.',
                    ),
                    DescComponents(
                      desc:
                          'Memang, seperti apa sih passing grade dalam tes CPNS? Mari kita pelajari sistem passing grade dari pelaksanaan seleksi CPNS 2019.',
                    ),
                    DescComponents(
                      desc:
                          'Di CPNS 2019, passing grade tercantum dalam Permenpan RB No. 24 Tahun 2019.',
                    ),
                    DescComponents(
                      desc:
                          'Berdasarkan Peraturan Menteri PANRB No. 24/2019 tentang Nilai Ambang Batas SKD Pengadaan CPNS 2019, para pelamar dengan jalur formasi umum dan formasi khusus tenaga pengamanan siber (cyber security) harus melampaui passing grade sebesar 126 untuk Tes Karakteristik Pribadi (TKP), 80 untuk Tes Intelegensia Umum (TIU), dan 65 untuk Tes Wawasan Kebangsaan (TWK). Dan kamu akan dinyatakan lulus bila passing grade perbagian (TKP, TIU, TWK) memperoleh nilai SKD minimal 271 poin dari jumlah 100 soal.',
                    ),
                    TitleComponents(
                      title: '8. Istirahatkan pikiran sebelum ujian dimulai',
                    ),
                    DescComponents(
                      desc:
                          'Saat kamu sudah mendekati hari ujian, usahakan untuk mengistirahatkan pikiran. Untuk sementara, jauhkan dulu latihan soal, materi, dan lainnya. Ini cara terbaik menghindari cemas yang bisa kamu alami.',
                    ),
                    DescComponents(
                      desc:
                          'Pikiran yang tenang akan memudahkan kamu saat mengerjakan soal ujian.',
                    ),
                    DescComponents(
                      desc:
                          'Apalagi nantinya kamu akan mengerjakan soal tes berbasis CAT yang membutuhkan konsentrasi tinggi. Jangan sampai karena kelelahan, malah menyulitkan kamu saat mengerjakan soal.',
                    ),
                    TitleComponents(title: '9. Pahami lokasi tes'),
                    DescComponents(
                      desc:
                          'Tips lolos seleksi CPNS selanjutnya, datanglah lebih awal ke lokasi tes. Ini untuk menghindari hal yang tidak diinginkan, seperti terjebak macet, tersesat menuju lokasi, dan lainnya. Datang lebih awal juga membantu kamu untuk lebih tenang.',
                    ),
                    TitleComponents(
                      title: '10. Teliti dan memperhatikan waktu',
                    ),
                    DescComponents(
                      desc:
                          'Saat mengerjakan soal-soal SKD dan SKB, kamu harus lebih teliti. Sebab, akan banyak soal-soal tes yang menjebak, dengan jawaban yang mirip-mirip. Dengan teliti, kamu juga bisa menjawab soal dengan cepat dan tepat.',
                    ),
                    DescComponents(
                      desc:
                          'Perlu kamu ketahui juga, dalam tes CPNS nanti, memperhatikan waktu adalah hal yang penting. Jangan sampai kamu membuang banyak waktu hanya untuk mengerjakan satu soal. Kerjakan terlebih dahulu soal yang menurut kamu mudah, seperti soal yang sifatnya hafalan. Tentunya jenis soal ini tidak akan memakan banyak waktu dibanding soal logika atau hitungan.',
                    ),
                    DescComponents(
                      desc:
                          'Soal SKD terdiri dari 35 soal TWK, 30 soal TIU, dan 35 soal TKP.',
                    ),
                    DescComponents(
                      desc:
                          'Beruntungnya, dalam sistem CAT, kamu bisa menandai soal yang kamu kira ragu jawabannya benar atau salahnya. Jadi, jika kamu masih ada waktu tersisa, kamu bisa cek ulang beberapa soal yang masih ragu.',
                    ),
                    DescComponents(
                      desc:
                          'Selanjutnya, kamu bisa mengerjakan soal-soal TKP dahulu. Soal-soal TKP ini berisikan pertanyaan seputar dirimu, dan tentunya tidak akan memakan banyak waktu. Tidak ada jawaban yang benar atau salah, hanya ada nilai paling tinggi dan paling rendah.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AdManager(
        showBanner: true,
        bannerAdUnitId: AdsConstants.bannerAdUnitId, // Gunakan ID dari constants
      ),
    );
  }
}
