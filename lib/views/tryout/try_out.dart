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
  late List categories;
  int currentCategoryIndex = 0;
  int currentQuestionIndex = 0;

  String? selectedOptionLabel;
  String? correctAnswerLabel;
  int? selectedScore;
  bool isAnswered = false;
  bool answerSaved = false;

  late int initialRemainingSeconds;

  List<Map<String, dynamic>> userAnswers = []; // This list holds saved answers
  List<Map<String, dynamic>> allQuestions = [];

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
    initialRemainingSeconds = widget.data['duration'];

    // Populate allQuestions list here
    _populateAllQuestions(); // New method to populate this list

    startTimer();
    _loadSavedAnswerForCurrentQuestion(); // Load answer for the initial question
  }

  void _populateAllQuestions() {
  for (var category in categories) {
    for (var quizItem in category['quiz']) {
      allQuestions.add({
        'questionText': quizItem['question']['text'],
        'options': quizItem['options'],
        'answer': quizItem['answer'], // The correct label, e.g., 'C'
        'explanation': quizItem['explanation'],
        'category': category['title'].toString().toUpperCase(), // Add category for filtering if needed
      });
    }
  }
}

  void startTimer() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds <= 0) {
        timer.cancel();
        // Automatically save current answer before showing final score if time runs out
        if (selectedOptionLabel != null && !answerSaved) {
          saveAnswer();
        }
        showFinalScore(); // Directly navigate to result page
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

  // New method to load the saved answer for the current question
  void _loadSavedAnswerForCurrentQuestion() {
    int currentOverall = _getCurrentOverallQuestionIndex();
    final existingAnswer = userAnswers.firstWhereOrNull(
        (ans) => ans['overallIndex'] == currentOverall);

    if (existingAnswer != null) {
      final List options = currentQuestion['options'];
      String? savedOptionLabel;

      if (existingAnswer['category'] == 'TKP') {
        savedOptionLabel = options.firstWhereOrNull(
          (opt) => opt['score'] == existingAnswer['score'],
        )?['label'];
      } else {
        savedOptionLabel = existingAnswer['selectedOptionLabel'];
      }

      setState(() {
        selectedOptionLabel = savedOptionLabel;
        isAnswered = true;
        answerSaved = true; // Mark as saved if an answer exists
        correctAnswerLabel = currentQuestion['answer'];
        selectedScore = existingAnswer['score']; // Load the score as well
      });
    } else {
      setState(() {
        selectedOptionLabel = null;
        isAnswered = false;
        answerSaved = false;
        selectedScore = null;
      });
    }
  }

  // Helper method to get the overall 0-based question index
  int _getCurrentOverallQuestionIndex() {
    int currentOverall = 0;
    for (int i = 0; i < currentCategoryIndex; i++) {
      currentOverall += (categories[i]['quiz'] as List).length;
    }
    currentOverall += currentQuestionIndex;
    return currentOverall;
  }


  void _selectOption(String label, {int? score}) {
    setState(() {
      selectedOptionLabel = label;
      isAnswered = true;
      selectedScore = score;
      correctAnswerLabel = currentQuestion['answer'];
      answerSaved = false; // Reset answerSaved when a new option is selected
    });
  }

  void nextQuestion() {
    setState(() {
      // Before moving, save the current answer if not already saved and an option is selected
      if (selectedOptionLabel != null && !answerSaved) {
        saveAnswer();
      }

      selectedOptionLabel = null;
      isAnswered = false;
      selectedScore = null;
      answerSaved = false;

      if (currentQuestionIndex <
          categories[currentCategoryIndex]['quiz'].length - 1) {
        currentQuestionIndex++;
      } else if (currentCategoryIndex < categories.length - 1) {
        currentCategoryIndex++;
        currentQuestionIndex = 0;
      }
      _loadSavedAnswerForCurrentQuestion(); // Load answer for the new question
    });
  }

  void previousQuestion() {
    setState(() {
      // Before moving, save the current answer if not already saved and an option is selected
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
        currentQuestionIndex =
            categories[currentCategoryIndex]['quiz'].length - 1;
      }
      _loadSavedAnswerForCurrentQuestion(); // Load answer for the new question
    });
  }

  void saveAnswer() {
  final String questionCategory = categories[currentCategoryIndex]['title'].toString().toUpperCase();

  if (selectedOptionLabel == null) return; // Only save if an option is selected

  bool isCorrect = selectedOptionLabel == correctAnswerLabel;

  int currentOverall = _getCurrentOverallQuestionIndex();

  setState(() {
    int existingAnswerIndex = userAnswers.indexWhere((ans) => ans['overallIndex'] == currentOverall);

    // Get the current question details to save
    final currentQ = currentQuestion; // Reference to the current question data
    final questionText = currentQ['question']['text'];
    final optionsData = currentQ['options']; // All options with labels, text, scores
    final correctAnsLabel = currentQ['answer']; // The correct answer label (e.g., 'A', 'B')
    final explanationText = currentQ['explanation'];

    if (existingAnswerIndex != -1) {
      userAnswers[existingAnswerIndex] = {
        'overallIndex': currentOverall,
        'category': questionCategory,
        'correct': questionCategory != 'TKP' ? isCorrect : null,
        'score': questionCategory == 'TKP' ? selectedScore : (isCorrect ? 5 : 0),
        'selectedOptionLabel': selectedOptionLabel,
        'questionText': questionText, // Save question text
        'options': optionsData,      // Save all options
        'correctAnswerLabel': correctAnsLabel, // Save correct answer label
        'explanation': explanationText, // Save the explanation here
      };
    } else {
      userAnswers.add({
        'overallIndex': currentOverall,
        'category': questionCategory,
        'correct': questionCategory != 'TKP' ? isCorrect : null,
        'score': questionCategory == 'TKP' ? selectedScore : (isCorrect ? 5 : 0),
        'selectedOptionLabel': selectedOptionLabel,
        'questionText': questionText,
        'options': optionsData,
        'correctAnswerLabel': correctAnsLabel,
        'explanation': explanationText, // Save the explanation here
      });
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
    (sum, cat) => sum + (cat['quiz'] as List).length,
  );

  int durationTaken = initialRemainingSeconds - remainingSeconds;

  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (context) => ResultPage(
        totalScore: totalScore,
        durationTakenInSeconds: durationTaken,
        userAnswers: userAnswers,
        totalQuestions: totalQuestionsCount, // This is already the total count
        twkScore: twkScore,
        tiuScore: tiuScore,
        tkpScore: tkpScore,
        allQuizQuestions: allQuestions, // <-- Pass the new allQuestions list
      ),
    ),
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

    int currentOverallNumber = _getCurrentOverallQuestionIndex() + 1; // 1-based for display

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
                        final bool isSelected = selectedOptionLabel == optionLabel;

                        final backgroundColor = isSelected
                            ? const Color(0xFF6A5AE0) // Changed to yellow for previously selected answer
                            : const Color(0xFFEFF1FE);
                        final textColor = isSelected
                            ? Colors.white // Text color for selected option
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
                            ? Colors.grey // Change color when saved
                            : const Color(0xFFFFE500), // Using #FFE500
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
            onPressed: () async { // Make onPressed async to await the dialog pop
              // First, save the current answer if not already saved
              if (selectedOptionLabel != null && !answerSaved) {
                saveAnswer();
              }

              // Show the dialog and wait for it to be dismissed
              final int? selectedOverallIndex = await showDialog<int>(
                context: context,
                builder: (context) => QuizModal(
                  totalQuestions: totalQuestions,
                  currentIndex: currentOverallNumber - 1, // Pass the 0-based overall index
                  userAnswers: userAnswers, // Pass the user answers
                  onSelectQuestion: (overallIndex) {
                    // This part is called when a number is clicked inside the modal.
                    // It will pop the dialog with the selected index as a result.
                    Navigator.of(context).pop(overallIndex); // THIS IS THE CRITICAL LINE
                  },
                ),
              );

              // Only update state if a number was actually selected (dialog wasn't just dismissed)
              if (selectedOverallIndex != null) {
                setState(() {
                  int tempOverallIndex = selectedOverallIndex;
                  currentCategoryIndex = 0;
                  currentQuestionIndex = 0;
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
                  _loadSavedAnswerForCurrentQuestion(); // Load answer for the newly selected question
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
                      // Save the current answer before showing final score if not already saved
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

// Add this extension for convenience to find elements in lists
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