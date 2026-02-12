import 'package:flutter/material.dart';
import 'package:siap_tka_sd/models/question_models.dart';
import 'package:siap_tka_sd/models/rich_text_content.dart';
import 'package:siap_tka_sd/widgets/rich_text_viewer.dart';

class ReviewPage extends StatelessWidget {
  final List<Question> questions;
  final Map<int, dynamic> userAnswers;

  const ReviewPage({
    super.key,
    required this.questions,
    required this.userAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Jawaban'),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: questions.length,
          itemBuilder: (context, index) {
            final question = questions[index];
            final userAnswer = userAnswers[index];
            return _buildReviewCard(context, index, question, userAnswer);
          },
        ),
      ),
    );
  }

  Widget _buildReviewCard(
      BuildContext context, int index, Question question, dynamic userAnswer) {
    bool isCorrect = _checkIsCorrect(question, userAnswer);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isCorrect ? Colors.green : Colors.red,
                  child: Text('${index + 1}',
                      style: const TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 12),
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  isCorrect ? 'Benar' : 'Salah',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            RichTextViewer(
              content: question.questionContent,
              defaultTextStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            const Text('Jawaban Anda:', style: TextStyle(fontWeight: FontWeight.bold)),
            _buildAnswerDisplay(question, userAnswer, isUser: true),
            if (!isCorrect) ...[
              const SizedBox(height: 12),
              const Text('Jawaban Benar:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              _buildAnswerDisplay(question, _getCorrectAnswer(question),
                  isUser: false),
            ],
          ],
        ),
      ),
    );
  }

  bool _checkIsCorrect(Question question, dynamic userAnswer) {
    if (question is MultipleChoiceQuestion) {
      return userAnswer == question.correctOptionId;
    } else if (question is MultiSelectQuestion) {
      final List<String> selectedIds = List<String>.from(userAnswer ?? []);
      final correctIds = question.correctOptionIds;
      return selectedIds.length == correctIds.length &&
          selectedIds.every((id) => correctIds.contains(id));
    } else if (question is ComplexMultipleChoiceQuestion) {
      final Map<String, bool> userMap = Map<String, bool>.from(userAnswer ?? {});
      final correctMap = question.correctAnswers;
      return userMap.length == correctMap.length &&
          correctMap.entries.every((e) => userMap[e.key] == e.value);
    }
    return false;
  }

  dynamic _getCorrectAnswer(Question question) {
    if (question is MultipleChoiceQuestion) {
      return question.correctOptionId;
    } else if (question is MultiSelectQuestion) {
      return question.correctOptionIds;
    } else if (question is ComplexMultipleChoiceQuestion) {
      return question.correctAnswers;
    }
    return null;
  }

  Widget _buildAnswerDisplay(Question question, dynamic answer, {required bool isUser}) {
    if (answer == null) return const Text('Tidak dijawab', style: TextStyle(fontStyle: FontStyle.italic));

    if (question is MultipleChoiceQuestion) {
      final option = question.options.firstWhere((o) => o.id == answer,
          orElse: () => Option(id: '', content: [TextData(text: 'Unknown')]));
      return RichTextViewer(content: option.content);
    } else if (question is MultiSelectQuestion) {
      final List<String> ids = List<String>.from(answer);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: ids.map((id) {
          final opt = question.options.firstWhere((o) => o.id == id,
              orElse: () => Option(id: '', content: [TextData(text: 'Unknown')]));
          return Row(
            children: [
              const Text('• '),
              Expanded(child: RichTextViewer(content: opt.content)),
            ],
          );
        }).toList(),
      );
    } else if (question is ComplexMultipleChoiceQuestion) {
      final Map<String, bool> map = Map<String, bool>.from(answer);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: question.statements.map((s) {
          final val = map[s.id];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: RichTextViewer(content: s.content)),
                const SizedBox(width: 8),
                Text(
                  ': ${val == true ? 'Benar' : (val == false ? 'Salah' : '-')}',
                  style: TextStyle(color: isUser ? null : Colors.green),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }
    return const SizedBox.shrink();
  }
}
