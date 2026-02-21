/// Disederhanakan untuk representasi teks biasa.
/// Anda dapat memperluasnya nanti untuk mendukung format rich text yang lebih kompleks.
library;

abstract class RichTextContent {
  String toPlainText();
  Map<String, dynamic> toJson();

  static RichTextContent fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'text':
        return TextData.fromJson(json);
      case 'math':
        return MathData.fromJson(json);
    // Tambahkan case lain jika ada tipe konten lain (misal: gambar, video)
      default:
        throw UnimplementedError('Unknown RichTextContent type: ${json['type']}');
    }
  }
}

/// Representasi konten teks sederhana dengan dukungan pemformatan dasar.
class TextData extends RichTextContent {
  final String text;
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;

  TextData({
    required this.text,
    this.isBold = false,
    this.isItalic = false,
    this.isUnderline = false,
  });

  @override
  String toPlainText() => text;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'text',
    'text': text,
    'isBold': isBold,
    'isItalic': isItalic,
    'isUnderline': isUnderline,
  };

  factory TextData.fromJson(Map<String, dynamic> json) {
    return TextData(
      text: json['text'],
      isBold: json['isBold'] ?? false,
      isItalic: json['isItalic'] ?? false,
      isUnderline: json['isUnderline'] ?? false,
    );
  }
}

/// Representasi konten matematika (LaTeX).
class MathData extends RichTextContent {
  final String formula;

  MathData({required this.formula});

  @override
  String toPlainText() => formula;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'math',
    'formula': formula,
  };

  factory MathData.fromJson(Map<String, dynamic> json) {
    return MathData(formula: json['formula']);
  }
}
