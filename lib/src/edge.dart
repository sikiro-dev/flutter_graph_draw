import 'package:flutter/material.dart';
import 'package:geometry/geometry.dart';
import 'package:flutter_graph_draw/src/node.dart';
import 'package:flutter_graph_draw/src/paragraph_painter.dart';
import 'package:flutter_graph_draw/src/edge_painter.dart';
import 'dart:ui' as ui;

enum EdgeType { Straight, Curved }

///this is an Edge of the graph
///
///[source] is the source node
///[target] is the target node
///[arrowWidth] is the width of the arrow (set to 0.0 for non_directed graphs)
///[ratio] is the curvature of the edge, it go from 10 to 50, only taken into consideration if [edgeType] is Curved
///[edgeType] can be Curved or Straight
///[color] is the color of the edge
///[paragraph] the edge can have a label attached on his center
///[alignment] is the aligment of the paragraph
///[padding] is the padding of the paragraph
class Edge extends StatefulWidget {
  final Node source;
  final Node target;
  final double arrowWidth;
  final double ratio;
  final EdgeType edgeType;
  final Color color;
  final ui.Paragraph paragraph;
  final Alignment alignment;
  final EdgeInsets padding;

  Edge(
      {@required this.source,
      @required this.target,
      this.arrowWidth = 0.0,
      this.ratio = 10.0,
      this.edgeType = EdgeType.Straight,
      this.color = Colors.black,
      this.paragraph,
      this.alignment = Alignment.centerRight,
      this.padding = const EdgeInsets.all(2.0)})
      : assert(source != null),
        assert(ratio >= 10.0 && ratio <= 50.0),
        assert(arrowWidth >= 0.0),
        assert(target != null);

  Rectangle get rectangle =>
      Rectangle(firstEdge: source.center, secondEdge: target.center);

  Arrow get edge {
    Point sourceCenter;
    Point targetCenter;
    if (source.center <= target.center) {
      sourceCenter = Point(0.0, 0.0);
      targetCenter = Point(rectangle.width, rectangle.heigth);
    } else if (source.center >= target.center) {
      sourceCenter = Point(rectangle.width, rectangle.heigth);
      targetCenter = Point(0.0, 0.0);
    } else if (source.center.wider(target.center)) {
      sourceCenter = Point(rectangle.width, 0.0);
      targetCenter = Point(0.0, rectangle.heigth);
    } else {
      sourceCenter = Point(0.0, rectangle.heigth);
      targetCenter = Point(rectangle.width, 0.0);
    }
    Point mid;
    Point tip;
    Shape body;
    Point end;
    Point start;
    List<Point> arrowTale;

    switch (edgeType) {
      case EdgeType.Straight:
        {
          mid = sourceCenter.midpoint(targetCenter);
          tip = mid.closer(Line.fromPoints(pointA: sourceCenter, pointB: mid)
              .intersec(Circle(center: targetCenter, radius: target.radius)));
          body = Line.fromPoints(pointA: sourceCenter, pointB: tip);
          start = mid.closer((body as Line)
              .intersec(Circle(center: sourceCenter, radius: source.radius)));
          end = mid.closer((body as Line).intersec(Circle(
              center: targetCenter,
              radius: target.radius + arrowWidth + 0.001)));
          arrowTale = (body as Line)
              .perpendicular(end)
              .atDistanceFromPoint(end, (arrowWidth + 0.001) / 2);
        }
        break;
      case EdgeType.Curved:
        {
          mid = Point.clockwise(
              sourceCenter,
              targetCenter,
              Line.fromPoints(pointA: sourceCenter, pointB: targetCenter)
                  .perpendicular(sourceCenter.midpoint(targetCenter))
                  .atDistanceFromPoint(sourceCenter.midpoint(targetCenter),
                      sourceCenter.distanceTo(targetCenter) / ratio),
              reversed: source.center.wider(target.center) &&
                  target.center.higher(source.center));
          tip = mid.closer(Circle.fromTreePoints(
                  pointA: sourceCenter, pointB: mid, pointC: targetCenter)
              .intersect(Circle(center: targetCenter, radius: target.radius)));
          body = Circle.fromTreePoints(
              pointA: sourceCenter, pointB: mid, pointC: targetCenter);
          start = mid.closer((body as Circle)
              .intersect(Circle(center: sourceCenter, radius: source.radius)));
          end = mid.closer((body as Circle).intersect(Circle(
              center: targetCenter, radius: target.radius + arrowWidth)));
          arrowTale =
              Line.fromPoints(pointA: end, pointB: (body as Circle).center)
                  .atDistanceFromPoint(end, arrowWidth / 2.0);
        }
        break;
      default:
    }

    return Arrow(
        start: start,
        end: end,
        mid: mid,
        body: body,
        left: arrowTale[0],
        rigth: arrowTale[1],
        tip: tip);
  }

  @override
  _EdgeState createState() => _EdgeState();
}

class _EdgeState extends State<Edge> with TickerProviderStateMixin {
  Node source;
  Node target;
  double arrowWidth;
  double ratio;
  EdgeType edgeType;
  Color color;
  ui.Paragraph paragraph;
  Alignment alignment;
  EdgeInsets padding;
  AnimationController controller;
  Animation<double> animation;
  double _fraction;

  @override
  void initState() {
    super.initState();
    source = widget.source;
    target = widget.target;
    arrowWidth = widget.arrowWidth;
    ratio = widget.ratio;
    edgeType = widget.edgeType;
    color = widget.color;
    paragraph = widget.paragraph;
    alignment = widget.alignment;
    padding = widget.padding;
    controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    animation = Tween(begin: 0.0, end: 1.0).animate(controller)
      ..addListener(() {
        setState(() {
          _fraction = animation.value;
        });
      });
    controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final actualEdge = widget.edge;
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        CustomPaint(
          painter: EdgePainter(
              fraction: _fraction,
              edge: actualEdge,
              color: color,
              hasLabel: paragraph != null),
          size: Size(widget.rectangle.width, widget.rectangle.heigth),
        ),
        paragraph != null
            ? Positioned(
                top: actualEdge.mid.y -
                    paragraph.height / 2.0 +
                    paragraph.height / 2.0 * alignment.y +
                    padding.top * alignment.y,
                left: actualEdge.mid.x -
                    paragraph.width / 2.0 +
                    paragraph.width / 2.0 * alignment.x +
                    padding.left * alignment.x,
                child: FadeTransition(
                  opacity: animation,
                  child: CustomPaint(
                    painter: ParagraphPainter(paragraph: paragraph),
                    size: Size(paragraph.width, paragraph.height),
                  ),
                ),
              )
            : Container(),
      ],
    );
  }
}
