import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_graph_draw/src/paragraph_painter.dart';
import 'package:geometry/geometry.dart';

class Node extends StatelessWidget {
  final double x;
  final double y;
  final double radius;
  final ui.Paragraph label;
  final Alignment alignment;
  final double padding;
  final WidgetBuilder builder;

  Node(
      {@required this.x,
      @required this.y,
      @required this.radius,
      this.builder,
      this.alignment = Alignment.centerRight,
      this.label,
      this.padding = 0.0})
      : assert(x != null),
        assert(y != null),
        assert(radius != null),
        assert(padding >= 0.0);

  Point get center => Point(x + radius, y + radius);

  @override
  Widget build(BuildContext context) {
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        Container(
          height: radius * 2.0,
          width: radius * 2.0,
          decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
          child: builder == null ? Container() : builder(context),
        ),
        label != null
            ? Positioned(
                top: alignment.y * radius +
                    padding * alignment.y +
                    radius -
                    label.height / 2.0 -
                    label.height / 2.0 * alignment.y,
                left: alignment.x * radius +
                    padding * alignment.x +
                    radius -
                    label.width / 2.0 +
                    label.width / 2.0 * alignment.x,
                child: CustomPaint(
                  size: Size(label.width, label.height),
                  painter: ParagraphPainter(paragraph: label),
                ),
              )
            : Container(),
      ],
    );
  }
}
