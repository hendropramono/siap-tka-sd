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
    // Tambahkan case lain jika ada tipe konten lain (misal: gambar, video)
      default:
        throw UnimplementedError('Unknown RichTextContent type: ${json['type']}');
    }
  }
}

/// Representasi konten teks sederhana.
class TextData extends RichTextContent {
  final String text;

  TextData({required this.text});

  @override
  String toPlainText() => text;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'text',
    'text': text,
  };

  factory TextData.fromJson(Map<String, dynamic> json) {
    return TextData(text: json['text']);
  }
}
