import 'package:flutter/material.dart';

class VerticalRouteLinePainter extends CustomPainter {
  final int stopCount;
  final double rowHeight;
  final double lineWidth;
  final Color lineColor;

  VerticalRouteLinePainter({
    required this.stopCount,
    this.rowHeight = 28,
    this.lineWidth = 2,
    this.lineColor = Colors.blueGrey,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth;
    // The circle is drawn at width/2 in the row, so the line should be at the same x
    final x = 14.0; // half of the 28 width used for the circle container in each row
    // Draw dashed vertical line
    const dashHeight = 6.0;
    const dashSpace = 4.0;
    // The circles are centered at rowHeight/2, so start and end at those points
    double startY = rowHeight / 2;
    final endY = (stopCount - 1) * rowHeight + rowHeight / 2;
    while (startY < endY) {
      final currentDashEnd = (startY + dashHeight).clamp(startY, endY);
      canvas.drawLine(
        Offset(x, startY),
        Offset(x, currentDashEnd.toDouble()),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
    // Draw circles at each stop
    final circleRadius = 7.0;
    for (int i = 0; i < stopCount; i++) {
      final cy = rowHeight / 2 + i * rowHeight;
      canvas.drawCircle(
        Offset(x, cy),
        circleRadius,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        Offset(x, cy),
        circleRadius,
        Paint()
          ..color = Colors.grey
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
