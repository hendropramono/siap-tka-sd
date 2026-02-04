import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:siap_tka_sd/models/question_models.dart';
import 'package:siap_tka_sd/models/rich_text_content.dart';
import 'package:siap_tka_sd/pages/result_page.dart';

class QuestionPage extends StatefulWidget {
  final String packageId;
  final String subjectTitle;

  const QuestionPage({
    super.key,
    required this.packageId,
    required this.subjectTitle,
  });

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  int _currentIndex = 0;
  final Map<int, dynamic> _userAnswers = {};
  List<Question>? _questions;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final packageDoc = await FirebaseFirestore.instance
          .collection('question_packages')
          .doc(widget.packageId)
          .get();

      if (!packageDoc.exists) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Paket soal tidak ditemukan';
        });
        return;
      }

      final List<dynamic> questionIds = packageDoc.data()?['questionIds'] ?? [];

      if (questionIds.isEmpty) {
        setState(() {
          _isLoading = false;
          _questions = [];
        });
        return;
      }

      final List<Future<DocumentSnapshot>> futures = questionIds
          .map((id) => FirebaseFirestore.instance
              .collection('questions')
              .doc(id.toString())
              .get())
          .toList();

      final snapshots = await Future.wait(futures);

      final List<Question> questions = [];
      for (var doc in snapshots) {
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          final type = data['type'] as String;

          if (type == QuestionType.multipleChoice.name) {
            questions.add(MultipleChoiceQuestion.fromJson(data));
          } else if (type == QuestionType.complexMultipleChoice.name) {
            questions.add(ComplexMultipleChoiceQuestion.fromJson(data));
          } else if (type == QuestionType.multiSelect.name) {
            questions.add(MultiSelectQuestion.fromJson(data));
          }
        }
      }

      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan: $e';
      });
    }
  }

  void _calculateResult() {
    if (_questions == null) return;

    int totalCorrect = 0;
    int totalScore = 0;
    int maxScore = 0;

    for (int i = 0; i < _questions!.length; i++) {
      final question = _questions![i];
      final userAnswer = _userAnswers[i];
      maxScore += question.points;

      bool isCorrect = false;

      if (question is MultipleChoiceQuestion) {
        if (userAnswer == question.correctOptionId) {
          isCorrect = true;
        }
      } else if (question is MultiSelectQuestion) {
        final List<String> selectedIds = List<String>.from(userAnswer ?? []);
        final correctIds = question.correctOptionIds;
        if (selectedIds.length == correctIds.length &&
            selectedIds.every((id) => correctIds.contains(id))) {
          isCorrect = true;
        }
      } else if (question is ComplexMultipleChoiceQuestion) {
        final Map<String, bool> userMap = Map<String, bool>.from(userAnswer ?? {});
        final correctMap = question.correctAnswers;
        if (userMap.length == correctMap.length &&
            correctMap.entries.every((e) => userMap[e.key] == e.value)) {
          isCorrect = true;
        }
      }

      if (isCorrect) {
        totalCorrect++;
        totalScore += question.points;
      }
    }

    // Hitung skor akhir skala 100
    final finalScore = (maxScore > 0) ? (totalScore / maxScore * 100).round() : 0;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          score: finalScore,
          totalQuestions: _questions!.length,
          correctAnswers: totalCorrect,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.subjectTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.subjectTitle)),
        body: Center(child: Text(_errorMessage!)),
      );
    }

    if (_questions == null || _questions!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.subjectTitle)),
        body: const Center(child: Text('Tidak ada soal tersedia')),
      );
    }

    final questions = _questions!;
    final currentQuestion = questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subjectTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (questions.isEmpty) ? 0 : (_currentIndex + 1) / questions.length,
            ),
            const SizedBox(height: 16),
            Text(
              'Soal ${_currentIndex + 1} dari ${questions.length}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (currentQuestion.instructionText != null)
              Text(
                currentQuestion.instructionText!,
                style: const TextStyle(
                    fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (currentQuestion.imageUrl != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Image.network(
                          currentQuestion.imageUrl!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ...currentQuestion.questionContent.map((content) =>
                        Text(content.toPlainText(),
                            style: const TextStyle(fontSize: 18))),
                    const SizedBox(height: 24),
                    _buildOptions(currentQuestion),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _currentIndex > 0
                      ? () => setState(() => _currentIndex--)
                      : null,
                  child: const Text('Sebelumnya'),
                ),
                ElevatedButton(
                  onPressed: _currentIndex < questions.length - 1
                      ? () => setState(() => _currentIndex++)
                      : _calculateResult,
                  child: Text(_currentIndex < questions.length - 1
                      ? 'Berikutnya'
                      : 'Selesai'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptions(Question question) {
    if (question is MultipleChoiceQuestion) {
      return Column(
        children: question.options.map((option) {
          return RadioListTile<String>(
            title: Text(option.content.map((c) => c.toPlainText()).join(' ')),
            value: option.id,
            groupValue: _userAnswers[_currentIndex] as String?,
            onChanged: (value) {
              setState(() {
                _userAnswers[_currentIndex] = value;
              });
            },
          );
        }).toList(),
      );
    } else if (question is MultiSelectQuestion) {
      final selectedIds = List<String>.from(_userAnswers[_currentIndex] ?? []);
      return Column(
        children: question.options.map((option) {
          return CheckboxListTile(
            title: Text(option.content.map((c) => c.toPlainText()).join(' ')),
            value: selectedIds.contains(option.id),
            onChanged: (bool? checked) {
              setState(() {
                if (checked == true) {
                  selectedIds.add(option.id);
                } else {
                  selectedIds.remove(option.id);
                }
                _userAnswers[_currentIndex] = selectedIds;
              });
            },
          );
        }).toList(),
      );
    } else if (question is ComplexMultipleChoiceQuestion) {
      final answers = Map<String, bool>.from(_userAnswers[_currentIndex] ?? {});
      return Column(
        children: question.statements.map((statement) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                    child: Text(statement.content
                        .map((c) => c.toPlainText())
                        .join(' '))),
                const Text('B'),
                Radio<bool>(
                  value: true,
                  groupValue: answers[statement.id],
                  onChanged: (val) {
                    setState(() {
                      answers[statement.id] = val!;
                      _userAnswers[_currentIndex] = answers;
                    });
                  },
                ),
                const Text('S'),
                Radio<bool>(
                  value: false,
                  groupValue: answers[statement.id],
                  onChanged: (val) {
                    setState(() {
                      answers[statement.id] = val!;
                      _userAnswers[_currentIndex] = answers;
                    });
                  },
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
