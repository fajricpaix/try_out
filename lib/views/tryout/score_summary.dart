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
    // Check if the options list is not null and not empty
    if (options.isNotEmpty) {
      final option = options.firstWhere(
        (opt) => opt['label'] == label,
        orElse: () => null,
      );
      if (option != null && option['text'] != null) {
        return '$label. ${option['text']}';
      }
    }
    return label; // Fallback if option text isn't found or options are invalid
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
      final currentQuestion = allQuizQuestions[i];
      final questionCategory = currentQuestion['category'] as String?;
      final userAnswerForThisQuestion =
          userAnswersMap[i]; // Get user's saved answer for this question index

      if (userAnswerForThisQuestion == null ||
          userAnswerForThisQuestion['selectedOptionLabel'] == null) {
        unansweredCount++;
      } else {
        // For TKP, correctness is determined by score, not direct answer match
        // Only increment correct/incorrect for non-TKP questions
        if (questionCategory != 'TKP') {
          final selectedOption =
              userAnswerForThisQuestion['selectedOptionLabel'];
          final correctOption = currentQuestion['answer'];

          if (selectedOption == correctOption) {
            correctCount++;
          } else {
            incorrectCount++;
          }
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
            Text(
              'Hasil Jawaban TWK & TIU:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A5AE0),
              ),
            ),
            Text(
              'Note: TKP tidak ada jawaban yang salah atau benar',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // TKP questions do not contribute to 'Benar' or 'Salah' counts directly.
                // These counts are specifically for TWK/TIU.
                _buildCountBox('Benar', correctCount, Colors.green),
                _buildCountBox('Salah', incorrectCount, Colors.red),
                _buildCountBox('Tidak Dijawab', unansweredCount, Colors.grey),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Detail Jawaban:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A5AE0),
              ),
            ),
            const SizedBox(height: 15),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allQuizQuestions.length,
              itemBuilder: (context, index) {
                final currentQuestionData = allQuizQuestions[index];
                final userAnswerData = userAnswersMap[index];

                final questionNumber = index + 1;
                final questionText = currentQuestionData['questionText'] ?? 'Soal tidak tersedia.';
                final allOptions = currentQuestionData['options'] as List<dynamic>;
                final correctOptionLabel = currentQuestionData['answer'] as String?;
                final explanation = currentQuestionData['explanation'] ?? 'Tidak ada penjelasan.';
                final questionCategory = currentQuestionData['category'] as String?;
                final selectedUserOptionLabel = userAnswerData?['selectedOptionLabel'] as String?;

                // For TKP questions, the score is retrieved from userAnswerData.
                // If not answered, it will be 0.
                final tkpUserScore = (questionCategory == 'TKP') ? (userAnswerData?['score'] ?? 0) : null;

                // Determine if the user's answer is correct for TWK/TIU display
                bool isCorrect = false;
                if (questionCategory != 'TKP' &&
                    selectedUserOptionLabel != null) {
                  isCorrect = (selectedUserOptionLabel == correctOptionLabel);
                }

                final formattedUserAnswer = selectedUserOptionLabel != null
                    ? _getFormattedOptionText( selectedUserOptionLabel, allOptions)
                      : 'Tidak Dijawab';

                final formattedCorrectAnswer = correctOptionLabel != null
                    ? _getFormattedOptionText(correctOptionLabel, allOptions)
                    : 'Jawaban Benar Tidak Tersedia';

                // Condition to check if it's a TKP question
                final bool isTKP = questionCategory == 'TKP';

                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Soal No. $questionNumber (${questionCategory ?? 'N/A'})',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6A5AE0),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          questionText,
                          style: const TextStyle(color: Colors.black87),
                        ),
                        const SizedBox(height: 12),

                        // Display user's answer (for all types)
                        _buildAnswerRow(
                          'Jawaban Anda:',
                          formattedUserAnswer,
                          selectedUserOptionLabel == null
                              ? Colors.grey // Not answered
                                : (isTKP ? Colors.blueAccent // Neutral highlight for TKP chosen answer
                                  : (isCorrect ? Colors.green : Colors.red)
                                  ),
                        ),

                        // Conditional content for TKP vs. non-TKP
                        if (!isTKP) ...[
                          // For TWK/TIU: show correct answer and explanation
                          Container(
                            height: 1,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey, width: 1.0),
                              ),
                            ),
                          ),
                          _buildAnswerRow(
                            'Jawaban Benar:',
                            formattedCorrectAnswer,
                            Colors.green,
                          ),
                          const SizedBox(height: 16),
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
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                            ),
                          ),
                        ] else ...[
                          // For TKP: show all options with their scores
                          const SizedBox(height: 16),
                          const Text(
                            'Pilihan Jawaban dan Skor:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6A5AE0),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Iterate through all options for TKP questions
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: allOptions.map<Widget>((option) {
                              final optionLabel = option['label'] as String;
                              final optionText = option['text'] as String;
                              final optionScore = option['score'] as int;
                              final bool isSelected = selectedUserOptionLabel == optionLabel;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$optionLabel.',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 4,
                                          horizontal: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4),
                                          color: isSelected ? Colors.blueAccent : Colors.transparent,
                                        ),
                                        child: Text(
                                          optionText,
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      height: 24,
                                      width: 24,
                                      decoration: BoxDecoration(
                                        color: Color(0xFF6A5AE0),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$optionScore',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          // Display TKP user's score at the end of the TKP section
                          if (tkpUserScore != null)
                            _buildScoreRow(
                              'Skor Anda untuk Soal ini:',
                              tkpUserScore,
                            ),
                        ],
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 1),
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
  // Split the value into option (e.g., "A.") and text (e.g., "Option Text")
  // We'll assume the format is "LABEL. TEXT"
  List<String> parts = value.split('. ');
  String optionLabelDisplay = '';
  String optionTextDisplay = value; // Default to full value if no split occurs

  if (parts.length > 1) {
    optionLabelDisplay = '${parts[0]}.'; // "A."
    optionTextDisplay = parts.sublist(1).join('. '); // "Option Text"
  } else {
    // Handle cases like "Tidak Dijawab" or "Jawaban Benar Tidak Tersedia"
    // where there is no option label.
    optionTextDisplay = value;
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 4),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left component
          if (optionLabelDisplay.isNotEmpty && optionLabelDisplay != value) ...[
            Text(
              optionLabelDisplay,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(width: 8),
          ], // Only show if it's a true option

          // Right component
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: valueColor,
              ),
              child: Text(
                optionTextDisplay,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
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
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF6A5AE0),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              score.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
