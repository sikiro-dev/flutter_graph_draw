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
class Node extends StatefulWidget {
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
  _NodeState createState() => _NodeState();
}

class _NodeState extends State<Node> with TickerProviderStateMixin {
  double x;
  double y;
  double radius;
  ui.Paragraph paragraph;
  Alignment alignment;
  EdgeInsets padding;
  WidgetBuilder builder;
  AnimationController controller;
  Animation<double> animation;
  double _fraction;

  @override
  initState() {
    super.initState();
    x = widget.x;
    y = widget.y;
    radius = widget.radius;
    paragraph = widget.paragraph;
    alignment = widget.alignment;
    padding = widget.padding;
    builder = widget.builder;
    controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    animation = CurveTween(curve: Curves.bounceInOut).animate(controller)
      ..addListener(() {
        setState(() {
          _fraction = animation.value;
        });
      });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        Container(
          height: radius * 2.0 * _fraction,
          width: radius * 2.0 * _fraction,
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
                child: FadeTransition(
                  opacity: animation,
                  child: CustomPaint(
                    size: Size(paragraph.width, paragraph.height),
                    painter: ParagraphPainter(paragraph: paragraph),
                  ),
                ),
              )
            : Container(),
      ],
    );
  }
}
