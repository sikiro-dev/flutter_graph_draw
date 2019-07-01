import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_graph_draw/src/paragraph_painter.dart';
import 'package:geometry/geometry.dart';

///rapresent a single node of the graph
///
///[x] and [y] are they offset from top and left
///[radius] is the radius of the node
///[paragraph] is the optional label of the node
///[alignment] is the alignment of the paragraph
///[padding] is the alignment of the paragraph
///[builder] is the builder if the node
class Node extends StatelessWidget {
  final double x;
  final double y;
  final double radius;
  final ui.Paragraph paragraph;
  final Alignment alignment;
  final EdgeInsets padding;
  final WidgetBuilder builder;

  Node(
      {@required this.x,
      @required this.y,
      @required this.radius,
      this.builder,
      this.alignment = Alignment.centerRight,
      this.paragraph,
      this.padding = const EdgeInsets.all(2.0)})
      : assert(x != null),
        assert(y != null),
        assert(radius != null);

  Point get center => Point(x + radius, y + radius);

  @override
  Widget build(BuildContext context) {
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        Container(
          height: radius * 2.0,
          width: radius * 2.0,
          child: builder == null
              ? Container(
                  decoration:
                      BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
                )
              : builder(context),
        ),
        paragraph != null
            ? Positioned(
                top: alignment.y * radius +
                    padding.top * alignment.y +
                    radius -
                    paragraph.height / 2.0 -
                    paragraph.height / 2.0 * alignment.y,
                left: alignment.x * radius +
                    padding.left * alignment.x +
                    radius -
                    paragraph.width / 2.0 +
                    paragraph.width / 2.0 * alignment.x,
                child: CustomPaint(
                  size: Size(paragraph.width, paragraph.height),
                  painter: ParagraphPainter(paragraph: paragraph),
                ),
              )
            : Container(),
      ],
    );
  }
}
