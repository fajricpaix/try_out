import 'package:flutter/material.dart';

class ScoreSummaryPage extends StatelessWidget {
  final List<Map<String, dynamic>> userAnswers;
  final int totalQuestions;
  final int twkScore;
  final int tiuScore;
  final int tkpScore;
  final List<Map<String, dynamic>> allQuizQuestions;

  const ScoreSummaryPage({
    super.key,
    required this.userAnswers,
    required this.totalQuestions,
    required this.twkScore,
    required this.tiuScore,
    required this.tkpScore,
    required this.allQuizQuestions,
  });

  // Helper function to format the answer text with option letter and content.
  String _getFormattedOptionText(String label, List<dynamic> options) {
    final option = options.firstWhere(
      (opt) => opt['label'] == label,
      orElse: () => null,
    );
    if (option != null && option['text'] != null) {
      return '$label. ${option['text']}';
    }
    return label; // Fallback if option text isn't found
  }

  @override
  Widget build(BuildContext context) {
    int correctCount = 0;
    int incorrectCount = 0;
    int unansweredCount = 0;

    // Create a map for quick lookup of user answers by overallIndex
    final Map<int, Map<String, dynamic>> userAnswersMap = {
      for (var ans in userAnswers) (ans['overallIndex'] as int): ans,
    };

    // Calculate counts for correct, incorrect, and unanswered questions
    for (int i = 0; i < allQuizQuestions.length; i++) {
      final userAnswerForThisQuestion =
          userAnswersMap[i]; // Get user's saved answer for this question index

      if (userAnswerForThisQuestion == null ||
          userAnswerForThisQuestion['selectedOptionLabel'] == null) {
        unansweredCount++;
      } else {
        final selectedOption = userAnswerForThisQuestion['selectedOptionLabel'];
        final correctOption =
            allQuizQuestions[i]['answer']; // Get correct answer from allQuizQuestions

        if (selectedOption == correctOption) {
          correctCount++;
        } else {
          incorrectCount++;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A5AE0),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Ringkasan Jawaban',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCountBox('Benar', correctCount, Colors.green),
              _buildCountBox('Salah', incorrectCount, Colors.red),
              _buildCountBox('Tidak Dijawab', unansweredCount, Colors.grey),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Detail Jawaban:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6A5AE0),
            ),
          ),
          const SizedBox(height: 15),
          // Loop through ALL questions to display them
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: allQuizQuestions.length, // Iterate over all questions
            itemBuilder: (context, index) {
              final currentQuestionData = allQuizQuestions[index]; // Get the original question
              final userAnswerData = userAnswersMap[index]; // Find the user's answer if it exists

              final questionNumber = index + 1; // 1-based index
              final questionText = currentQuestionData['questionText'] ?? 'Soal tidak tersedia.';
              final allOptions = currentQuestionData['options'] as List<dynamic>;
              final correctOptionLabel = currentQuestionData['answer'] as String?;
              final explanation = currentQuestionData['explanation'] ?? 'Tidak ada penjelasan.';
              final questionCategory = currentQuestionData['category'] as String?;

              final selectedUserOptionLabel = userAnswerData?['selectedOptionLabel'] as String?;
              final tkpUserScore = (questionCategory == 'TKP' && userAnswerData != null)
                  ? (userAnswerData['score'] ?? 0)
                  : null;

              // Determine if the user's answer is correct for display purposes
              bool isCorrect = (selectedUserOptionLabel == correctOptionLabel);

              final formattedUserAnswer = selectedUserOptionLabel != null
                  ? _getFormattedOptionText(selectedUserOptionLabel, allOptions)
                  : 'Tidak Dijawab'; // If no user answer found, it was not answered

              final formattedCorrectAnswer = correctOptionLabel != null
                  ? _getFormattedOptionText(correctOptionLabel, allOptions)
                  : 'Jawaban Benar Tidak Tersedia';

              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Soal No. $questionNumber (${questionCategory ?? 'N/A'})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6A5AE0),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        questionText,
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 15),
                      _buildAnswerRow(
                        'Jawaban Anda:',
                        formattedUserAnswer,
                        selectedUserOptionLabel == null
                            ? Colors.grey // Not answered
                            : (isCorrect ? Colors.green : Colors.red),
                      ),
                      const SizedBox(height: 8),
                      _buildAnswerRow('Jawaban Benar:', formattedCorrectAnswer, Colors.green),
                      if (tkpUserScore != null) ...[
                        const SizedBox(height: 8),
                        _buildScoreRow('Skor TKP Anda:', tkpUserScore),
                      ],
                      const SizedBox(height: 15),
                      const Text(
                        'Penjelasan:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6A5AE0),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        explanation,
                        style: const TextStyle(fontSize: 15, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ),
    );
  }

  // Helper widget to build a count display box (Correct, Incorrect, Unanswered)
  Widget _buildCountBox(String title, int count, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(
          vertical: 8,
        ), // Added vertical padding
        decoration: BoxDecoration(
          color: color.withOpacity(0.1), // Light background color
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color,
            width: 1,
          ), // Border with primary color
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(title, style: TextStyle(fontSize: 14, color: color)),
          ],
        ),
      ),
    );
  }

  // Helper widget to display a row for user's answer or correct answer
  Widget _buildAnswerRow(String label, String value, Color valueColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: valueColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // Helper widget to display the TKP score for a specific question
  Widget _buildScoreRow(String label, int score) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          score.toString(),
          style: const TextStyle(
            fontSize: 15,
            color: Colors.purple, // Distinct color for TKP score
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
