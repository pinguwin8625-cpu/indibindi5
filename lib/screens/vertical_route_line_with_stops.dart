import 'package:flutter/material.dart';

class VerticalRouteLineWithStops extends StatelessWidget {
  final int stopCount;
  final double rowHeight;
  final double lineWidth;
  final double circleRadius;
  final Color lineColor;
  final Color circleColor;

  const VerticalRouteLineWithStops({
    super.key,
    required this.stopCount,
    this.rowHeight = 28,
    this.lineWidth = 2,
    this.circleRadius = 6,
    this.lineColor = Colors.blueGrey,
    this.circleColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(lineWidth + circleRadius * 2, stopCount * rowHeight),
      painter: _VerticalRouteLinePainter(
        stopCount: stopCount,
        rowHeight: rowHeight,
        lineWidth: lineWidth,
        circleRadius: circleRadius,
        lineColor: lineColor,
        circleColor: circleColor,
      ),
    );
  }
}

class _VerticalRouteLinePainter extends CustomPainter {
  final int stopCount;
  final double rowHeight;
  final double lineWidth;
  final double circleRadius;
  final Color lineColor;
  final Color circleColor;

  _VerticalRouteLinePainter({
    required this.stopCount,
    required this.rowHeight,
    required this.lineWidth,
    required this.circleRadius,
    required this.lineColor,
    required this.circleColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth;
    final circlePaint = Paint()
      ..color = circleColor
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw the vertical line
    final x = size.width / 2;
    canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);

    // Draw circles for each stop
    for (int i = 0; i < stopCount; i++) {
      final y = i * rowHeight + rowHeight / 2;
      canvas.drawCircle(Offset(x, y), circleRadius, circlePaint);
      canvas.drawCircle(Offset(x, y), circleRadius, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
