import 'dart:async';
import 'package:flutter/material.dart';
import 'package:try_out/widgets/modal/confirmation_dialog.dart';
import 'package:try_out/widgets/modal/quiz.dart'; // Ensure this path is correct
import 'package:google_mobile_ads/google_mobile_ads.dart';

class TryOutViews extends StatefulWidget {
  final Map<String, dynamic> data;
  const TryOutViews({super.key, required this.data});

  @override
  State<TryOutViews> createState() => _TryOutViewsState();
}

class _TryOutViewsState extends State<TryOutViews> {
  late List categories;
  int currentCategoryIndex = 0;
  int currentQuestionIndex = 0;

  // Ads
  InterstitialAd? _interstitialAd;
  bool _isAdReady = false;

  String? selectedOptionLabel;
  String? correctAnswerLabel;
  int? selectedScore;
  bool isAnswered = false;
  bool answerSaved = false;

  List<Map<String, dynamic>> userAnswers = [];

  late int remainingSeconds;
  Timer? countdownTimer;

  Map<String, dynamic> get currentQuestion {
    return categories[currentCategoryIndex]['quiz'][currentQuestionIndex];
  }

  // Ads
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
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('InterstitialAd failed to load: $error');
          _isAdReady = false;
        },
      ),
    );
  }

  void _showAdAndThenFinalScore() {
    if (_isAdReady && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitialAd(); // Muat ulang untuk sesi selanjutnya
          showFinalScore();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          showFinalScore();
        },
      );
      _interstitialAd!.show();
    } else {
      showFinalScore(); // Jika iklan belum siap
    }
  }

  @override
  void initState() {
    super.initState();
    categories = widget.data['category'];
    remainingSeconds = widget.data['duration'];
    startTimer();
    _loadInterstitialAd();
  }

  void startTimer() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds <= 0) {
        timer.cancel();
        showFinalScore();
      } else {
        setState(() {
          remainingSeconds--;
        });
      }
    });
  }

  String formatDuration(int seconds) {
    final Duration duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    _interstitialAd?.dispose(); // Dispose the ad when the widget is disposed
    super.dispose();
  }

  void _selectOption(String label, {int? score}) {
    setState(() {
      selectedOptionLabel = label;
      isAnswered = true;
      selectedScore = score;
      correctAnswerLabel = currentQuestion['answer'];
    });
  }

  void nextQuestion() {
    setState(() {
      answerSaved = false;
      selectedOptionLabel = null;
      isAnswered = false;
      selectedScore = null;

      if (currentQuestionIndex <
          categories[currentCategoryIndex]['quiz'].length - 1) {
        currentQuestionIndex++;
      } else if (currentCategoryIndex < categories.length - 1) {
        currentCategoryIndex++;
        currentQuestionIndex = 0;
      }
    });
  }

  void previousQuestion() {
    setState(() {
      answerSaved = false;
      selectedOptionLabel = null;
      isAnswered = false;
      selectedScore = null;

      if (currentQuestionIndex > 0) {
        currentQuestionIndex--;
      } else if (currentCategoryIndex > 0) {
        currentCategoryIndex--;
        currentQuestionIndex =
            categories[currentCategoryIndex]['quiz'].length - 1;
      }
    });
  }

  void saveAnswer() {
  final category = categories[currentCategoryIndex]['title'];
  final questionType = category.toLowerCase();

  if (selectedOptionLabel == null) return;

  bool isCorrect = selectedOptionLabel == correctAnswerLabel;

  // Calculate current overall question number before saving
  int currentOverall = 0;
  for (int i = 0; i < currentCategoryIndex; i++) {
    currentOverall += (categories[i]['quiz'] as List).length;
  }
  currentOverall += currentQuestionIndex; // 0-based index for saving

  setState(() {
    // Check if an answer for this question already exists and update it
    // Or add a new answer if it doesn't exist
    int existingAnswerIndex = userAnswers.indexWhere((ans) => ans['overallIndex'] == currentOverall);

    if (existingAnswerIndex != -1) {
      // Update existing answer
      userAnswers[existingAnswerIndex] = {
        'overallIndex': currentOverall, // Add overall index
        'type': questionType,
        'correct': questionType != 'tkp' ? isCorrect : null,
        'score': questionType == 'tkp' ? selectedScore : (isCorrect ? 5 : 0),
      };
    } else {
      // Add new answer
      userAnswers.add({
        'overallIndex': currentOverall, // Add overall index
        'type': questionType,
        'correct': questionType != 'tkp' ? isCorrect : null,
        'score': questionType == 'tkp' ? selectedScore : (isCorrect ? 5 : 0),
      });
    }
    answerSaved = true;
  });
}

  void showFinalScore() {
  int totalScore = userAnswers.fold(0, (sum, ans) {
    final score = ans['score'];
    return sum + (score is int ? score : (score as num?)?.toInt() ?? 0);
  });

  // Calculate total questions again, for safety in case it's not globally accessible
  int totalQuestions = categories.fold(
    0,
    (sum, cat) => sum + (cat['quiz'] as List).length,
  );

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Total Skor Anda: $totalScore", 
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold
              )
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(totalQuestions, (overallIndex) { // Iterate based on totalQuestions
                // Find the answer for this specific overall question index
                final userAnswer = userAnswers.firstWhereOrNull(
                  (ans) => ans['overallIndex'] == overallIndex,
                );

                Color color;
                String displayText;

                if (userAnswer != null) {
                  final isCorrect = userAnswer['correct'];
                  final isTkp = userAnswer['type'] == 'tkp';
                  final score = userAnswer['score'];

                  if (isTkp) {
                    // For TKP, we assume any score means it was answered, color based on presence of score.
                    // If you have a specific passing score for TKP to determine green/red, you'd add that logic.
                    // For now, if answered, it's green.
                    color = Colors.green;
                    displayText = '${overallIndex + 1}. ($score)';
                  } else {
                    // For non-TKP, green if correct, red if incorrect.
                    color = isCorrect == true ? Colors.green : Colors.red;
                    displayText = '${overallIndex + 1}';
                  }
                } else {
                  // No answer saved for this question
                  color = Colors.grey; // Grey for unanswered
                  displayText = '${overallIndex + 1}';
                }

                return Container(
                  width: 56,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    displayText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      );
    },
  );
}

  bool isLastQuestion() {
    return currentCategoryIndex == categories.length - 1 &&
        currentQuestionIndex == categories.last['quiz'].length - 1;
  }

  @override
  Widget build(BuildContext context) {
    final questionText = currentQuestion['question']['text'];
    final options = currentQuestion['options'];

    int totalQuestions = categories.fold(
      0,
      (sum, cat) => sum + (cat['quiz'] as List).length,
    );

    int currentOverallNumber = 0;
    for (int i = 0; i < currentCategoryIndex; i++) {
      currentOverallNumber += (categories[i]['quiz'] as List).length;
    }
    currentOverallNumber += currentQuestionIndex + 1;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Latihan Soal',
          style: TextStyle(color: Colors.white),
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
                              'Soal: $currentOverallNumber dari $totalQuestions',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              formatDuration(remainingSeconds),
                              style: const TextStyle(fontSize: 12),
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
                        final int? optionScore = opt['score'];
                        final bool isSelected =
                            selectedOptionLabel == optionLabel;

                        final backgroundColor = isSelected
                            ? const Color(0xFF6A5AE0)
                            : const Color(0xFFEFF1FE);
                        final textColor = isSelected
                            ? Colors.white
                            : const Color(0xFF6A5AE0);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Text(
                                '$optionLabel.',
                                style: const TextStyle(
                                  color: Color(0xFF604FDE),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: backgroundColor,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () => _selectOption(
                                    optionLabel,
                                    score: optionScore,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      optionText,
                                      style: TextStyle(color: textColor),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ElevatedButton(
                      onPressed: answerSaved ? null : saveAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: answerSaved
                            ? Colors.grey // Change color when saved
                            : const Color(0xFFF8C005),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        answerSaved ? "Jawaban Tersimpan" : "Simpan Jawaban",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor:
                      currentCategoryIndex == 0 && currentQuestionIndex == 0
                          ? Colors.white60
                          : const Color(0xFF6A5AE0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: (currentCategoryIndex == 0 && currentQuestionIndex == 0)
                    ? null // Disable if on the first question
                    : previousQuestion,
                child: Icon(
                  Icons.keyboard_arrow_left,
                  color: (currentCategoryIndex == 0 && currentQuestionIndex == 0)
                      ? Colors.black26
                      : Colors.white,
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
                    totalQuestions: totalQuestions,
                    currentIndex: currentOverallNumber - 1, // Pass the 0-based overall index
                    onSelectQuestion: (overallIndex) {
                      setState(() {
                        // Calculate category and question index from overallIndex
                        int tempOverallIndex = overallIndex;
                        currentCategoryIndex = 0; // Reset category index
                        currentQuestionIndex = 0; // Reset question index
                        for (int i = 0; i < categories.length; i++) {
                          final categoryQuizLength = (categories[i]['quiz'] as List).length;
                          if (tempOverallIndex < categoryQuizLength) {
                            currentCategoryIndex = i;
                            currentQuestionIndex = tempOverallIndex;
                            break;
                          } else {
                            tempOverallIndex -= categoryQuizLength;
                          }
                        }
                        // Reset selection and answer saved status when navigating to a new question
                        selectedOptionLabel = null;
                        isAnswered = false;
                        selectedScore = null;
                        answerSaved = false;
                      });
                    },
                  ),
                );
              },
              child: Text(
                '$currentOverallNumber',
                style: const TextStyle(color: Color(0xFF6A5AE0), fontSize: 16),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: isLastQuestion()
                      ? Colors.green.shade500
                      : const Color(0xFF6A5AE0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  if (isLastQuestion()) {
                    _showAdAndThenFinalScore();
                  } else {
                    nextQuestion();
                  }
                },
                child: isLastQuestion()
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

extension on List<Map<String, dynamic>> {
  firstWhereOrNull(bool Function(dynamic ans) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}