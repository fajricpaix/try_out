import 'package:flutter/material.dart';

class ScoreSummaryPage extends StatelessWidget {
  final List<Map<String, dynamic>> userAnswers;
  final int totalQuestions;
  final int twkScore; // Overall TWK score
  final int tiuScore; // Overall TIU score
  final int tkpScore; // Overall TKP score

  const ScoreSummaryPage({
    super.key,
    required this.userAnswers,
    required this.totalQuestions,
    required this.twkScore,
    required this.tiuScore,
    required this.tkpScore,
  });

  // Helper function to format the answer text, including option letters if available.
  // It handles cases where the answer is an index (int) or the direct option text (String).
  String _getAnswerText(Map<String, dynamic> answer, dynamic value) {
    if (answer['options'] != null && answer['options'] is List) {
      final options = List<String>.from(answer['options']);
      if (value is int && value >= 0 && value < options.length) {
        // If the value is an integer, treat it as an index and return "A. Option Text"
        return '${String.fromCharCode(65 + value)}. ${options[value]}';
      } else if (value is String) {
        // If the value is already a string, try to find it in options to prefix with letter
        for (int i = 0; i < options.length; i++) {
          if (options[i] == value) {
            return '${String.fromCharCode(65 + i)}. $value';
          }
        }
        return value; // Fallback if the string value doesn't match an option text
      }
    }
    return value.toString(); // Fallback for other types or if options are missing
  }

  @override
  Widget build(BuildContext context) {
    int correctCount = 0;
    int incorrectCount = 0;
    int unansweredCount = 0;

    // Calculate counts for correct, incorrect, and unanswered questions
    for (var answer in userAnswers) {
      if (answer['userAnswer'] == null || answer['userAnswer'].toString().isEmpty) {
        unansweredCount++;
      } else if (answer['userAnswer'] == answer['correctAnswer']) {
        correctCount++;
      } else {
        incorrectCount++;
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A5AE0),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ringkasan Jawaban',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A5AE0),
              ),
            ),
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
            // Section Title for detailed answers
            Text(
              'Detail Jawaban:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A5AE0),
              ),
            ),
            const SizedBox(height: 15),
            // ListView for individual question summaries
            ListView.builder(
              shrinkWrap: true, // Allows ListView to take only as much space as its children
              physics: NeverScrollableScrollPhysics(), // Disables scrolling for this inner ListView
              itemCount: userAnswers.length,
              itemBuilder: (context, index) {
                final answer = userAnswers[index];
                // Safely retrieve question data, providing fallbacks if keys are missing
                final questionNumber = answer['questionNumber'] ?? (index + 1);
                final questionText = answer['questionText'] ?? 'Soal tidak tersedia.';
                final userAnswer = _getAnswerText(answer, answer['userAnswer']);
                final correctAnswer = _getAnswerText(answer, answer['correctAnswer']);
                final explanation = answer['explanation'] ?? 'Tidak ada penjelasan.';
                final questionType = answer['type']; // e.g., 'TWK', 'TIU', 'TKP'
                // Retrieve TKP score if the question type is 'TKP'
                final tkpUserScore = (questionType == 'TKP') ? (answer['score'] ?? 0) : null;

                // Determine if the user's answer is correct
                bool isCorrect = (answer['userAnswer'] == answer['correctAnswer']);

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
                        // Question Number
                        Text(
                          'Soal No. $questionNumber',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6A5AE0),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Question Text
                        Text(
                          questionText,
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        const SizedBox(height: 15),
                        // User's Answer
                        _buildAnswerRow('Jawaban Anda:', userAnswer, isCorrect ? Colors.green : Colors.red),
                        const SizedBox(height: 8),
                        // Correct Answer
                        _buildAnswerRow('Jawaban Benar:', correctAnswer, Colors.green),
                        // Display TKP score only if the question is of type 'TKP'
                        if (tkpUserScore != null) ...[
                          const SizedBox(height: 8),
                          _buildScoreRow('Skor TKP Anda:', tkpUserScore),
                        ],
                        const SizedBox(height: 15),
                        // Explanation Title
                        Text(
                          'Penjelasan:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6A5AE0),
                          ),
                        ),
                        const SizedBox(height: 5),
                        // Explanation Text
                        Text(
                          explanation,
                          style: TextStyle(fontSize: 15, color: Colors.black54),
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

  // New Helper widget to build a count display box (Correct, Incorrect, Unanswered)
  Widget _buildCountBox(String title, int count, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: color.withOpacity(0.1), // Light background color
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 1), // Border with primary color
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
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: color,
              ),
            ),
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
          style: TextStyle(
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
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          score.toString(),
          style: TextStyle(
            fontSize: 15,
            color: Colors.purple, // Distinct color for TKP score
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
