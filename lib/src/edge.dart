import 'package:flutter/material.dart';
import 'package:geometry_kp/geometry.dart';
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
class Edge extends StatelessWidget {
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
        assert(ratio >= 0.0),
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
          );
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
  Widget build(BuildContext context) {
    final actualEdge = edge;
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        CustomPaint(
          painter: EdgePainter(
              edge: actualEdge, color: color, hasLabel: paragraph != null),
          size: Size(rectangle.width, rectangle.heigth),
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
                child: CustomPaint(
                  painter: ParagraphPainter(paragraph: paragraph),
                  size: Size(paragraph.width, paragraph.height),
                ),
              )
            : Container(),
      ],
    );
  }
}
