import 'package:flutter/material.dart';
import 'package:flutter_graph_draw/src/node.dart';
import 'package:flutter_graph_draw/src/edge.dart';
import 'dart:ui' as ui;

class Graph extends StatelessWidget {
  final List<Node> nodes;
  final List<Edge> edges;

  Graph({@required this.nodes, @required this.edges})
      : assert(nodes != null),
        assert(edges != null);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ...edges
            .map((edge) => Positioned(
                top: edge.rectangle.lowEdge.y,
                left: edge.rectangle.lowEdge.x,
                child: edge))
            .toList(),
        ...nodes
            .map((node) => Positioned(
                  top: node.y,
                  left: node.x,
                  child: node,
                ))
            .toList(),
      ],
    );
  }
}
