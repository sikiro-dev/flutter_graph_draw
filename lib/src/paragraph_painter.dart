import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ParagraphPainter extends CustomPainter {
  final ui.Paragraph paragraph;

  ParagraphPainter({@required this.paragraph}) : assert(paragraph != null);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    canvas.drawParagraph(paragraph, Offset(0, 0));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
