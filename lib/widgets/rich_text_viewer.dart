import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../models/rich_text_content.dart';

class RichTextViewer extends StatelessWidget {
  final List<RichTextContent> content;
  final TextStyle defaultTextStyle;

  const RichTextViewer({
    super.key,
    required this.content,
    this.defaultTextStyle = const TextStyle(fontSize: 16, height: 1.5),
  });

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) {
      return const SizedBox.shrink();
    }
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: content.map((block) => _buildBlock(context, block)).toList(),
    );
  }

  Widget _buildBlock(BuildContext context, RichTextContent block) {
    if (block is TextData) {
      return Text(block.text, style: defaultTextStyle);
    } else if (block is MathData) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Math.tex(
          block.formula,
          textStyle: TextStyle(fontSize: defaultTextStyle.fontSize ?? 16),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
