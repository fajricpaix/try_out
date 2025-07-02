import 'dart:async';
import 'package:flutter/material.dart';
import 'package:try_out/views/tryout/result.dart';
import 'package:try_out/widgets/modal/confirm_finish.dart';
import 'package:try_out/widgets/modal/confirmation_dialog.dart';
import 'package:try_out/widgets/modal/quiz.dart';

class TryOutViews extends StatefulWidget {
  final Map<String, dynamic> data;
  const TryOutViews({super.key, required this.data});

  @override
  State<TryOutViews> createState() => _TryOutViewsState();
}

class _TryOutViewsState extends State<TryOutViews> {
  // Now explicitly declare as List<Map<String, dynamic>>
  late List<Map<String, dynamic>> categories;
  int currentCategoryIndex = 0;
  int currentQuestionIndex = 0;

  String? selectedOptionLabel;
  String? correctAnswerLabel;
  int? selectedScore;
  bool isAnswered = false;
  bool answerSaved = false;

  late int initialRemainingSeconds;

  List<Map<String, dynamic>> userAnswers = [];
  List<Map<String, dynamic>> allQuestions = [];

  late int remainingSeconds;
  Timer? countdownTimer;

  Map<String, dynamic> get currentQuestion {
    // This is already safe because `categories` is now strongly typed.
    return categories[currentCategoryIndex]['quiz'][currentQuestionIndex];
  }

  @override
  void initState() {
    super.initState();
    _processIncomingData(); // Process data first to ensure strong types

    remainingSeconds = widget.data['duration'] as int;
    initialRemainingSeconds = widget.data['duration'] as int;

    _populateAllQuestions(); // Now `categories` will have correct types here
    startTimer();
    _loadSavedAnswerForCurrentQuestion();
  }

  // --- MODIFIED: Helper to recursively process and cast all Maps and Lists ---
  void _processIncomingData() {
    final dynamic rawCategories = widget.data['category'];
    if (rawCategories is List) {
      // Here's the key change: use .cast<Map<String, dynamic>>() on the list result
      categories = rawCategories.map((cat) {
        if (cat is Map) {
          return _castMapToStrongType(cat);
        }
        return cat;
      }).toList().cast<Map<String, dynamic>>(); // Explicit cast to List<Map<String, dynamic>>
    } else {
      categories = [];
      debugPrint('Warning: widget.data[\'category\'] is not a List. Check Firebase structure.');
    }
  }

  Map<String, dynamic> _castMapToStrongType(Map<dynamic, dynamic> inputMap) {
    Map<String, dynamic> newMap = {};
    inputMap.forEach((key, value) {
      if (key is String) {
        if (value is Map && value is! Map<String, dynamic>) {
          newMap[key] = _castMapToStrongType(value);
        } else if (value is List) {
          // Here's another key change: cast list elements if they are maps
          newMap[key] = value.map((item) {
            if (item is Map && item is! Map<String, dynamic>) {
              return _castMapToStrongType(item);
            }
            return item;
          }).toList(); // No need for .cast() here yet, as the individual items are handled.
        } else {
          newMap[key] = value;
        }
      } else {
        debugPrint('Warning: Non-string key "$key" found in map. Converting key to string.');
        newMap[key.toString()] = value;
      }
    });
    return newMap;
  }
  // --- END MODIFIED HELPER ---

  void _populateAllQuestions() {
    allQuestions = [];
    for (var category in categories) {
      // Ensure 'quiz' is cast correctly when accessed
      final List<dynamic> quizListDynamic = category['quiz'] as List<dynamic>;
      // Now, iterate through this dynamic list and cast each item
      final List<Map<String, dynamic>> quizList = quizListDynamic
          .map((quizItem) => quizItem as Map<String, dynamic>) // Explicitly cast each item
          .toList();

      for (var quizItem in quizList) { // Now quizItem is definitely Map<String, dynamic>
        allQuestions.add({
          'questionText': quizItem['question']['text'],
          'options': quizItem['options'],
          'answer': quizItem['answer'],
          'explanation': quizItem['explanation'],
          'category': category['title'].toString().toUpperCase(),
        });
      }
    }
  }

  void startTimer() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds <= 0) {
        timer.cancel();
        if (selectedOptionLabel != null && !answerSaved) {
          saveAnswer();
        }
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

  void _loadSavedAnswerForCurrentQuestion() {
    int currentOverall = _getCurrentOverallQuestionIndex();
    final existingAnswer = userAnswers.firstWhereOrNull(
      (ans) => ans['overallIndex'] == currentOverall,
    );

    if (existingAnswer != null) {
      final List<dynamic> options = currentQuestion['options'] as List<dynamic>;
      String? savedOptionLabel;

      if (existingAnswer['category'] == 'TKP') {
        savedOptionLabel = options.firstWhereOrNull(
          (opt) => (opt as Map<String, dynamic>)['score'] == existingAnswer['score'],
        )?['label'] as String?;
      } else {
        savedOptionLabel = existingAnswer['selectedOptionLabel'] as String?;
      }

      setState(() {
        selectedOptionLabel = savedOptionLabel;
        isAnswered = true;
        answerSaved = true;
        correctAnswerLabel = currentQuestion['answer'] as String?;
        selectedScore = existingAnswer['score'] as int?;
      });
    } else {
      setState(() {
        selectedOptionLabel = null;
        isAnswered = false;
        answerSaved = false;
        selectedScore = null;
        correctAnswerLabel = currentQuestion['answer'] as String?;
      });
    }
  }

  int _getCurrentOverallQuestionIndex() {
    int currentOverall = 0;
    for (int i = 0; i < currentCategoryIndex; i++) {
      // Cast here as well for safety, though `categories` is already typed.
      currentOverall += (categories[i]['quiz'] as List<dynamic>).length;
    }
    currentOverall += currentQuestionIndex;
    return currentOverall;
  }

  void _selectOption(String label, {int? score}) {
    setState(() {
      selectedOptionLabel = label;
      isAnswered = true;
      selectedScore = score;
      correctAnswerLabel = currentQuestion['answer'] as String?;
      answerSaved = false;
    });
  }

  void nextQuestion() {
    setState(() {
      if (selectedOptionLabel != null && !answerSaved) {
        saveAnswer();
      }

      selectedOptionLabel = null;
      isAnswered = false;
      selectedScore = null;
      answerSaved = false;

      // Accessing `quiz` and its length safely
      if (currentQuestionIndex < (categories[currentCategoryIndex]['quiz'] as List<dynamic>).length - 1) {
        currentQuestionIndex++;
      } else if (currentCategoryIndex < categories.length - 1) {
        currentCategoryIndex++;
        currentQuestionIndex = 0;
      }
      _loadSavedAnswerForCurrentQuestion();
    });
  }

  void previousQuestion() {
    setState(() {
      if (selectedOptionLabel != null && !answerSaved) {
        saveAnswer();
      }

      selectedOptionLabel = null;
      isAnswered = false;
      selectedScore = null;
      answerSaved = false;

      if (currentQuestionIndex > 0) {
        currentQuestionIndex--;
      } else if (currentCategoryIndex > 0) {
        currentCategoryIndex--;
        // Accessing `quiz` and its length safely
        currentQuestionIndex = (categories[currentCategoryIndex]['quiz'] as List<dynamic>).length - 1;
      }
      _loadSavedAnswerForCurrentQuestion();
    });
  }

  void saveAnswer() {
    final String questionCategory = categories[currentCategoryIndex]['title'].toString().toUpperCase();

    if (selectedOptionLabel == null) return;

    bool isCorrect = selectedOptionLabel == correctAnswerLabel;

    int currentOverall = _getCurrentOverallQuestionIndex();

    setState(() {
      int existingAnswerIndex = userAnswers.indexWhere((ans) => ans['overallIndex'] == currentOverall);

      final Map<String, dynamic> currentQ = currentQuestion;
      final String questionText = currentQ['question']['text'] as String;
      // Accessing options safely
      final List<dynamic> optionsData = currentQ['options'] as List<dynamic>;
      final String? correctAnsLabel = currentQ['answer'] as String?;
      final String? explanationText = currentQ['explanation'] as String?;

      final Map<String, dynamic> newAnswer = {
        'overallIndex': currentOverall,
        'category': questionCategory,
        'correct': questionCategory != 'TKP' ? isCorrect : null,
        'score': questionCategory == 'TKP' ? selectedScore : (isCorrect ? 5 : 0),
        'selectedOptionLabel': selectedOptionLabel,
        'questionText': questionText,
        'options': optionsData,
        'correctAnswerLabel': correctAnsLabel,
        'explanation': explanationText,
      };

      if (existingAnswerIndex != -1) {
        userAnswers[existingAnswerIndex] = newAnswer;
      } else {
        userAnswers.add(newAnswer);
      }
      answerSaved = true;
    });
  }

  void showFinalScore() {
    countdownTimer?.cancel();

    int totalScore = 0;
    int twkScore = 0;
    int tiuScore = 0;
    int tkpScore = 0;

    for (var ans in userAnswers) {
      final score = ans['score'];
      final category = ans['category'];

      int currentQuestionScore = (score is int ? score : (score as num?)?.toInt() ?? 0);
      totalScore += currentQuestionScore;

      if (category == 'TWK') {
        twkScore += currentQuestionScore;
      } else if (category == 'TIU') {
        tiuScore += currentQuestionScore;
      } else if (category == 'TKP') {
        tkpScore += currentQuestionScore;
      }
    }

    int totalQuestionsCount = categories.fold(
      0,
      (sum, cat) => sum + (cat['quiz'] as List<dynamic>).length, // Cast `quiz`
    );

    int durationTaken = initialRemainingSeconds - remainingSeconds;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ResultPage(
          totalScore: totalScore,
          durationTakenInSeconds: durationTaken,
          userAnswers: userAnswers,
          totalQuestions: totalQuestionsCount,
          twkScore: twkScore,
          tiuScore: tiuScore,
          tkpScore: tkpScore,
          allQuizQuestions: allQuestions,
        ),
      ),
    );
  }

  bool isLastQuestion() {
    return currentCategoryIndex == categories.length - 1 &&
        currentQuestionIndex == (categories.last['quiz'] as List<dynamic>).length - 1; // Cast `quiz`
  }

  @override
  Widget build(BuildContext context) {
    final String questionText = currentQuestion['question']['text'] as String;
    // Cast options here before mapping
    final List<Map<String, dynamic>> options = (currentQuestion['options'] as List<dynamic>)
        .map((opt) => opt as Map<String, dynamic>)
        .toList();

    int totalQuestions = categories.fold(
      0,
      (sum, cat) => sum + (cat['quiz'] as List<dynamic>).length, // Cast `quiz`
    );

    int currentOverallNumber = _getCurrentOverallQuestionIndex() + 1;

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
                      // options is now List<Map<String, dynamic>> due to the cast above
                      children: options.map<Widget>((optionMap) {
                        final optionLabel = optionMap['label'] as String;
                        final optionText = optionMap['text'] as String;
                        final int? optionScore = optionMap['score'] as int?;

                        final bool isSelected = selectedOptionLabel == optionLabel;

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
                    child: ElevatedButton(
                      onPressed: answerSaved ? null : saveAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: answerSaved
                            ? Colors.grey
                            : const Color(0xFFFFE500),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        answerSaved ? "Jawaban Tersimpan" : "Simpan Jawaban",
                        style: const TextStyle(
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
                    ? null
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
            onPressed: () async {
              if (selectedOptionLabel != null && !answerSaved) {
                saveAnswer();
              }

              final int? selectedOverallIndex = await showDialog<int>(
                context: context,
                builder: (context) => QuizModal(
                  totalQuestions: totalQuestions,
                  currentIndex: currentOverallNumber - 1,
                  userAnswers: userAnswers,
                  onSelectQuestion: (overallIndex) {
                    Navigator.of(context).pop(overallIndex);
                  },
                ),
              );

              if (selectedOverallIndex != null) {
                setState(() {
                  int tempOverallIndex = selectedOverallIndex;
                  currentCategoryIndex = 0;
                  currentQuestionIndex = 0;
                  for (int i = 0; i < categories.length; i++) {
                    final categoryQuizLength = (categories[i]['quiz'] as List<dynamic>).length;
                    if (tempOverallIndex < categoryQuizLength) {
                      currentCategoryIndex = i;
                      currentQuestionIndex = tempOverallIndex;
                      break;
                    } else {
                      tempOverallIndex -= categoryQuizLength;
                    }
                  }
                  _loadSavedAnswerForCurrentQuestion();
                });
              }
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
                onPressed: () async {
                  if (isLastQuestion()) {
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (context) => const ConfirmationFinish(
                        title: 'Selesai Ujian?',
                        content: 'Apakah Anda yakin ingin menyelesaikan ujian?',
                        confirmButtonText: 'Selesai',
                        cancelButtonText: 'Lanjutkan',
                      ),
                    );

                    if (result == true) {
                      if (selectedOptionLabel != null && !answerSaved) {
                        saveAnswer();
                      }
                      showFinalScore();
                    }
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

extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}