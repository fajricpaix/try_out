import 'package:flutter/material.dart';
import 'package:try_out/widgets/modal/confirmation_dialog.dart';
import 'package:try_out/widgets/modal/quiz.dart';
import 'package:try_out/widgets/tools/select_quiz_button.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class QuizView extends StatefulWidget {
  final List<dynamic> quizData;
  const QuizView({super.key, required this.quizData});

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  List<dynamic> _quizQuestions = [];
  int _currentIndex = 0;
  List<String?> _selectedOptions = [];
  List<int?> _selectedScores = []; // New: To store scores for TKP questions
  List<bool> _answeredStatus = [];
  bool _isLoading = true;

  // Ads
  InterstitialAd? _interstitialAd;
  bool _isAdReady = false;

  void _loadInterstitialAd() {
    InterstitialAd.load(
      // Dev ID
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', // TEST ID, replace with real one
      // Production ID
      // adUnitId = 'ca-app-pub-2602479093941928/9052001071';
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isAdReady = true;

          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
                onAdDismissedFullScreenContent: (ad) {
                  ad.dispose();
                  Navigator.pop(context); // Kembali setelah iklan
                },
                onAdFailedToShowFullScreenContent: (ad, error) {
                  ad.dispose();
                  Navigator.pop(context); // Tetap kembali jika gagal tampil
                },
              );
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd gagal dimuat: $error');
          _isAdReady = false;
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadQuizData();
    _loadInterstitialAd();
  }

  void _loadQuizData() {
    setState(() {
      _quizQuestions = widget.quizData;
      _isLoading = false;
      _selectedOptions = List<String?>.filled(_quizQuestions.length, null);
      _selectedScores = List<int?>.filled(
        _quizQuestions.length,
        null,
      ); // Initialize scores for TKP
      _answeredStatus = List<bool>.filled(_quizQuestions.length, false);
    });
  }

  void _selectOption(String optionLabel, {int? score}) {
    // Modified: added score parameter
    if (!_answeredStatus[_currentIndex]) {
      setState(() {
        _selectedOptions[_currentIndex] = optionLabel;
        if (score != null) {
          _selectedScores[_currentIndex] = score;
        }
      });
    }
  }

  void _checkAnswer() {
    if (_selectedOptions[_currentIndex] == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih jawaban dulu')));
      return;
    }

    setState(() {
      _answeredStatus[_currentIndex] = true;
    });
  }

  void _goToNextQuestion() {
    if (_currentIndex < _quizQuestions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _goToPreviousQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF6A5AE0),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_quizQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Latihan Soal',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF6A5AE0),
        ),
        body: const Center(
          child: Text(
            'No quiz questions loaded.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    var currentQuestion = _quizQuestions[_currentIndex];
    final String questionText = currentQuestion['question']['text'];
    final List options = currentQuestion['options'];
    final String? correctAnswerLabel =
        currentQuestion['answer']; // Can be null for TKP
    final String? explanation =
        currentQuestion['explanation']; // Can be null for TKP
    final isAnswered = _answeredStatus[_currentIndex];
    final selectedOptionLabel = _selectedOptions[_currentIndex];
    final selectedScore = _selectedScores[_currentIndex]; // New: for TKP score

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Latihan Soal',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF6A5AE0),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () async {
            final result = await showDialog<bool>(
              context: context,
              builder: (context) => const ConfirmationDialog(),
            );
            if (result == true) {
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.ballot_rounded,
              color: Colors.white,
              size: 28,
            ),
            tooltip: 'Lihat Semua Soal',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => QuizModal(
                  totalQuestions: _quizQuestions.length,
                  currentIndex: _currentIndex,
                  onSelectQuestion: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  }, 
                  userAnswers: [],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFF6A5AE0),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(22),
                  bottomRight: Radius.circular(22),
                ),
              ),
            ),
            Container(
              transform: Matrix4.translationValues(0, -70, 0),
              child: Column(
                children: [
                  // Questions Box
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 4,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Soal ${_currentIndex + 1} dari ${_quizQuestions.length}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          questionText,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),

                  // Questions Select
                  Container(
                    transform: Matrix4.translationValues(0, 24, 0),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Column(
                      children: options.map<Widget>((opt) {
                        final optionLabel = opt['label'];
                        final optionText = opt['text'];
                        final int? optionScore =
                            opt['score']; // Get score for TKP
                        final bool isTKP = selectedScore != null;
                        return SelectQuizButton(
                          label: optionLabel,
                          text: optionText,
                          isSelected: selectedOptionLabel == optionLabel,
                          onPressed: () =>
                              _selectOption(optionLabel, score: optionScore),
                          // Modified: If it's a TKP question and answered, always show as 'correct' if selected
                          isCorrect:
                              isAnswered &&
                              ((isTKP &&
                                      selectedOptionLabel ==
                                          optionLabel) || // If TKP, selected option is 'correct'
                                  (!isTKP &&
                                      optionLabel ==
                                          correctAnswerLabel)), // Else, use correctAnswerLabel for non-TKP
                          showResult: isAnswered,
                          // Modified: If it's a TKP question, never show as 'wrong'
                          isWrong:
                              isAnswered &&
                              !isTKP &&
                              selectedOptionLabel == optionLabel &&
                              optionLabel != correctAnswerLabel,
                        );
                      }).toList(),
                    ),
                  ),

                  // Questions Check Result Button
                  if (!isAnswered && selectedOptionLabel != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ElevatedButton(
                        onPressed: _checkAnswer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF8C005),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Periksa jawaban?",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                  // Questions Result
                  if (isAnswered)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedScore != null
                                    ? 'Skor Anda'
                                    : 'Pembahasan',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6A5AE0),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  selectedScore != null
                                      ? 'Skor Anda: $selectedScore'
                                      : 'Jawaban: $correctAnswerLabel',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: selectedScore != null ? 0 : 12),
                          if (explanation !=
                              null) // Show explanation for non-TKP
                            Text(
                              explanation,
                              style: const TextStyle(fontSize: 16),
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: 32,
          top: 12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: _currentIndex == 0
                      ? Colors.white60
                      : const Color(0xFF6A5AE0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _currentIndex == 0 ? null : _goToPreviousQuestion,
                child: Icon(
                  Icons.keyboard_arrow_left,
                  color: _currentIndex == 0 ? Colors.black26 : Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: const Color(0xFFEFF1FE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => QuizModal(
                    totalQuestions: _quizQuestions.length,
                    currentIndex: _currentIndex,
                    onSelectQuestion: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                );
              },
              child: Text(
                '${_currentIndex + 1}',
                style: const TextStyle(color: Color(0xFF6A5AE0), fontSize: 16),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: _currentIndex == _quizQuestions.length - 1
                      ? Colors.green.shade500
                      : const Color(0xFF6A5AE0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed:
                    (_currentIndex == _quizQuestions.length - 1 && !isAnswered)
                    ? null
                    : (_currentIndex == _quizQuestions.length - 1 && isAnswered)
                    ? () {
                        if (_isAdReady && _interstitialAd != null) {
                          _interstitialAd!.show();
                        } else {
                          Navigator.pop(context); // fallback jika iklan gagal
                        }
                      }
                    : _goToNextQuestion,
                child: _currentIndex == _quizQuestions.length - 1
                    ? const Text(
                        'Selesai',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      )
                    : const Icon(
                        Icons.keyboard_arrow_right,
                        color: Colors.white,
                        size: 24,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
