import 'dart:async';
import 'package:flutter/material.dart';
import 'package:try_out/widgets/modal/confirmation_dialog.dart';
import 'package:try_out/widgets/modal/quiz.dart';

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

  @override
  void initState() {
    super.initState();
    categories = widget.data['category'];
    remainingSeconds = widget.data['duration'];
    startTimer();
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

    setState(() {
      userAnswers.add({
        'type': questionType,
        'correct': questionType != 'tkp' ? isCorrect : null,
        'score': questionType == 'tkp' ? selectedScore : (isCorrect ? 5 : 0),
      });
      answerSaved = true;
    });
  }

  void showFinalScore() {
    int totalScore = userAnswers.fold(0, (sum, ans) {
      final score = ans['score'];
      return sum + (score is int ? score : (score as num?)?.toInt() ?? 0);
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Nilai Akhir"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Total Skor Anda: $totalScore"),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(userAnswers.length, (index) {
                  final isCorrect = userAnswers[index]['correct'];
                  final isTkp = userAnswers[index]['type'] == 'tkp';
                  final score = userAnswers[index]['score'];
                  final color = isCorrect == true
                      ? Colors.green
                      : (isCorrect == false ? Colors.red : Colors.green);
                  return Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isTkp ? '${index + 1}. ($score)' : '${index + 1}',
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
                            ? Color(0xFF6A5AE0)
                            : Color(0xFFEFF1FE);
                        final textColor = isSelected
                            ? Colors.white
                            : Color(0xFF6A5AE0);

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
                            ? Colors.red
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
                onPressed: previousQuestion,
                child: Icon(
                  Icons.keyboard_arrow_left,
                  color: totalQuestions == 0 ? Colors.black26 : Colors.white,
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
                    currentIndex: currentQuestionIndex,
                    onSelectQuestion: (index) {
                      setState(() {
                        currentQuestionIndex = index;
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
                    showFinalScore();
                  } else {
                    nextQuestion();
                  }
                },
                child: isLastQuestion()
                    ? Text(
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
