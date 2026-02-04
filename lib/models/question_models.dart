import 'rich_text_content.dart';

// Enum untuk tipe soal, bisa diperluas nanti
enum QuestionType {
  multipleChoice,
  complexMultipleChoice, // Benar-Salah
  multiSelect,          // Centang (Multiple Response)
}

/// Kelas dasar untuk semua soal. Saat ini hanya sebagai fondasi.
abstract class Question {
  final String id;
  final QuestionType type;
  final List<RichTextContent> questionContent;
  final String? instructionText;
  final int points;
  final String? imageUrl; // Tambahkan properti ini

  Question({
    required this.id,
    required this.type,
    required this.questionContent,
    this.instructionText,
    required this.points,
    this.imageUrl, // Tambahkan ini ke konstruktor
  });

  Map<String, dynamic> toJson();
}

/// Model untuk satu opsi jawaban dalam soal pilihan ganda.
class Option {
  final String id;
  final List<RichTextContent> content;

  Option({required this.id, required this.content});

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content.map((c) => c.toJson()).toList(),
      };

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'],
      content: (json['content'] as List)
          .map((c) => RichTextContent.fromJson(c))
          .toList(),
    );
  }
}

/// Model untuk Soal Pilihan Ganda.
class MultipleChoiceQuestion extends Question {
  final List<Option> options;
  final String correctOptionId;

  MultipleChoiceQuestion({
    required super.id,
    required super.questionContent,
    required this.options,
    required this.correctOptionId,
    super.instructionText,
    super.points = 1,
    super.imageUrl, // Tambahkan ini ke konstruktor super
  }) : super(type: QuestionType.multipleChoice);

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'questionContent': questionContent.map((c) => c.toJson()).toList(),
      'options': options.map((o) => o.toJson()).toList(),
      'correctOptionId': correctOptionId,
      'instructionText': instructionText,
      'points': points,
      'imageUrl': imageUrl, // Tambahkan ini ke JSON
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  factory MultipleChoiceQuestion.fromJson(Map<String, dynamic> json) {
    return MultipleChoiceQuestion(
      id: json['id'],
      questionContent: (json['questionContent'] as List)
          .map((c) => RichTextContent.fromJson(c))
          .toList(),
      options: (json['options'] as List)
          .map((o) => Option.fromJson(o))
          .toList(),
      correctOptionId: json['correctOptionId'],
      instructionText: json['instructionText'],
      points: json['points'] ?? 1,
      imageUrl: json['imageUrl'], // Tambahkan ini dari JSON
    );
  }
}

/// Model untuk Soal Pilihan Ganda Kompleks (Benar-Salah).
class ComplexMultipleChoiceQuestion extends Question {
  final List<Option> statements;
  final Map<String, bool> correctAnswers;

  ComplexMultipleChoiceQuestion({
    required super.id,
    required super.questionContent,
    required this.statements,
    required this.correctAnswers,
    super.instructionText,
    super.points = 1,
    super.imageUrl,
  }) : super(type: QuestionType.complexMultipleChoice);

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'questionContent': questionContent.map((c) => c.toJson()).toList(),
      'statements': statements.map((s) => s.toJson()).toList(),
      'correctAnswers': correctAnswers,
      'instructionText': instructionText,
      'points': points,
      'imageUrl': imageUrl,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  factory ComplexMultipleChoiceQuestion.fromJson(Map<String, dynamic> json) {
    return ComplexMultipleChoiceQuestion(
      id: json['id'],
      questionContent: (json['questionContent'] as List)
          .map((c) => RichTextContent.fromJson(c))
          .toList(),
      statements: (json['statements'] as List)
          .map((s) => Option.fromJson(s))
          .toList(),
      correctAnswers: Map<String, bool>.from(json['correctAnswers']),
      instructionText: json['instructionText'],
      points: json['points'] ?? 1,
      imageUrl: json['imageUrl'],
    );
  }
}

/// Model untuk Soal Pilihan Ganda Kompleks (Centang/Multi-select).
class MultiSelectQuestion extends Question {
  final List<Option> options;
  final List<String> correctOptionIds;

  MultiSelectQuestion({
    required super.id,
    required super.questionContent,
    required this.options,
    required this.correctOptionIds,
    super.instructionText,
    super.points = 1,
    super.imageUrl,
  }) : super(type: QuestionType.multiSelect);

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'questionContent': questionContent.map((c) => c.toJson()).toList(),
      'options': options.map((o) => o.toJson()).toList(),
      'correctOptionIds': correctOptionIds,
      'instructionText': instructionText,
      'points': points,
      'imageUrl': imageUrl,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  factory MultiSelectQuestion.fromJson(Map<String, dynamic> json) {
    return MultiSelectQuestion(
      id: json['id'],
      questionContent: (json['questionContent'] as List)
          .map((c) => RichTextContent.fromJson(c))
          .toList(),
      options: (json['options'] as List)
          .map((o) => Option.fromJson(o))
          .toList(),
      correctOptionIds: List<String>.from(json['correctOptionIds']),
      instructionText: json['instructionText'],
      points: json['points'] ?? 1,
      imageUrl: json['imageUrl'],
    );
  }
}
