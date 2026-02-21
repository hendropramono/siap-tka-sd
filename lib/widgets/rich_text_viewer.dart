import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../models/rich_text_content.dart';

class RichTextViewer extends StatelessWidget {
  final List<RichTextContent> content;
  final TextStyle? style;

  const RichTextViewer({
    super.key,
    required this.content,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) {
      return const SizedBox.shrink();
    }

    final effectiveTextStyle = style ?? Theme.of(context).textTheme.bodyLarge?.copyWith(
      fontSize: 16,
      height: 1.5,
    ) ?? const TextStyle(fontSize: 16, height: 1.5);

    return Text.rich(
      TextSpan(
        children: content.map((block) => _buildSpan(context, block, effectiveTextStyle)).toList(),
      ),
      style: effectiveTextStyle,
    );
  }

  InlineSpan _buildSpan(BuildContext context, RichTextContent block, TextStyle baseStyle) {
    if (block is TextData) {
      return TextSpan(
        text: block.text,
        style: baseStyle.copyWith(
          fontWeight: block.isBold ? FontWeight.bold : baseStyle.fontWeight,
          fontStyle: block.isItalic ? FontStyle.italic : baseStyle.fontStyle,
          decoration: block.isUnderline ? TextDecoration.underline : baseStyle.decoration,
        ),
      );
    } else if (block is MathData) {
      return WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Math.tex(
            block.formula,
            textStyle: baseStyle.copyWith(
              fontSize: baseStyle.fontSize,
            ),
          ),
        ),
      );
    }
    return const TextSpan(text: '');
  }
}
