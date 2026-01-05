import 'package:flutter/material.dart';
import 'package:try_out/main.dart';
import 'package:try_out/views/tryout/score_summary.dart';
import 'package:try_out/widgets/ads/ads_constant.dart';
// Import komponen AdManager
import 'package:try_out/widgets/ads/ads_manager.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ResultPage extends StatefulWidget {
  final int totalScore;
  final int durationTakenInSeconds;
  final List<Map<String, dynamic>> userAnswers;
  final int totalQuestions;
  final int twkScore;
  final int tiuScore;
  final int tkpScore;
  final List<Map<String, dynamic>> allQuizQuestions;

  const ResultPage({
    super.key,
    required this.totalScore,
    required this.durationTakenInSeconds,
    required this.userAnswers,
    required this.totalQuestions,
    required this.twkScore,
    required this.tiuScore,
    required this.tkpScore,
    required this.allQuizQuestions,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _shareResult() async {
    try {
      setState(() { _isSharing = true; });
      final boundary = _repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mengambil screenshot')));
        return;
      }
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memproses gambar')));
        return;
      }
      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/result_${DateTime.now().millisecondsSinceEpoch}.png').create();
      await file.writeAsBytes(pngBytes);
      // ignore: deprecated_member_use
      await Share.shareXFiles([XFile(file.path)], text: 'Lihat hasil saya: https://play.google.com/store/apps/details?id=com.candramawa.try_out&pcampaignid=web_share');
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() { _isSharing = false; });
    }
  }

  String _formatDuration(int seconds) {
    final Duration duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: RepaintBoundary(
          key: _repaintBoundaryKey,
          child: Container(
            margin: const EdgeInsets.only(top: 48),
          padding: const EdgeInsets.all(20.0),
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Score TryOut
              Container(
                width: 275,
                height: 275,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      widget.twkScore > 64 ||
                              widget.tiuScore > 79 ||
                              widget.tkpScore > 165
                          ? 'assets/training/success.webp'
                          : 'assets/training/un_success.webp',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'SKOR ANDA',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${widget.totalScore}',
                        style: const TextStyle(
                          fontSize: 76,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title and Description
              Text(
                widget.twkScore > 64 ||
                        widget.tiuScore > 79 ||
                        widget.tkpScore > 165
                    ? 'SELAMAT!\nKAMU LULUS'
                    : 'OOUUUCH!\nKAMU BELUM LULUS',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color:
                      widget.twkScore > 64 ||
                          widget.tiuScore > 79 ||
                          widget.tkpScore > 165
                      ? const Color(0xFF6A5AE0)
                      : const Color(0xFFE53935),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Display the "Passing Grade Detail" button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildScoreBox(
                    'TWK',
                    widget.twkScore,
                    65,
                    widget.twkScore > 64
                        ? const Color(0xFF14AE5C)
                        : const Color(0xFFF71D1D)
                  ),
                  const SizedBox(width: 10),
                  _buildScoreBox(
                    'TIU',
                    widget.tiuScore,
                    80,
                    widget.tiuScore > 79
                        ? const Color(0xFF14AE5C)
                        : const Color(0xFFF71D1D)
                  ),
                  const SizedBox(width: 10),
                  _buildScoreBox(
                    'TKP',
                    widget.tkpScore,
                    166,
                    widget.tkpScore > 165
                        ? const Color(0xFF14AE5C)
                        : const Color(0xFFF71D1D)
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Duration
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    color: const Color(0xFF6A5AE0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Durasi Penyelesaian',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                          Text(
                            _formatDuration(widget.durationTakenInSeconds),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Button Check Summary Answers
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ScoreSummaryPage(
                          userAnswers: widget.userAnswers,
                          totalQuestions: widget.totalQuestions,
                          twkScore: widget.twkScore,
                          tiuScore: widget.tiuScore,
                          tkpScore: widget.tkpScore,
                          allQuizQuestions: widget.allQuizQuestions,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFE500),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Lihat Detail Jawaban',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Button Shared and Back to Home
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                margin: const EdgeInsets.only(top: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: const Color(0xFFEFF1FE),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _isSharing ? null : () {
                          _shareResult();
                        },
                        child: _isSharing
                            ? SizedBox(
                                height: 24,
                                child: Center(
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.0,
                                      color: Color(0xFF6A5AE0),
                                    ),
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.share_outlined,
                                    color: Color(0xFF6A5AE0),
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Shared',
                                    style: TextStyle(
                                      color: Color(0xFF6A5AE0),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: const Color(0xFF6A5AE0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyHomePage(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        },
                        child: const Text(
                          'Kembali ke Beranda',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
      // Gunakan AdManager untuk menampilkan banner ad dan interstitial ad
      bottomNavigationBar: const AdManager(
        showBanner: true,
        bannerAdUnitId: AdsConstants.bannerAdUnitId,
      ),
    );
  }

  // Helper method to build a score box
  Widget _buildScoreBox(
    // ignore: strict_top_level_inference
    title,
    int score,
    int passScore,
    Color valueColor
  ) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        color: valueColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$score',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '/$passScore',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
