import 'package:flutter/material.dart';

/// A custom painter that draws a vertical dashed line with circles for stops.
/// Supports coloring the line segment between origin and destination in green,
/// and greying out stops outside the selected range.
class RouteLineWithStopsPainter extends CustomPainter {
  final int stopCount;
  final double rowHeight;
  final double lineWidth;
  final Color lineColor;
  final int? originIndex;
  final int? destinationIndex;
  final List<int>? greyedStops;

  RouteLineWithStopsPainter({
    required this.stopCount,
    this.rowHeight = 28,
    this.lineWidth = 2,
    this.lineColor = const Color(0xFF2E2E2E), // Neutral dark grey
    this.originIndex,
    this.destinationIndex,
    this.greyedStops,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final x = 14.0;
    const dashHeight = 6.0;
    const dashSpace = 4.0;

    // Draw dashed line segments between stops
    for (int i = 0; i < stopCount - 1; i++) {
      final yStart = rowHeight / 2 + i * rowHeight;
      final yEnd = rowHeight / 2 + (i + 1) * rowHeight;

      // Determine segment color
      Color segmentColor = lineColor;
      if (originIndex != null && destinationIndex != null) {
        int start = originIndex! < destinationIndex!
            ? originIndex!
            : destinationIndex!;
        int end = originIndex! > destinationIndex!
            ? originIndex!
            : destinationIndex!;
        if (i >= start && i < end) {
          // Use neutral dark grey for route
          segmentColor = Color(0xFF2E2E2E); // Neutral dark grey
        }
      }

      // Check if this segment should be greyed out
      final isGrey =
          greyedStops != null &&
          (greyedStops!.contains(i) || greyedStops!.contains(i + 1));
      final paint = Paint()
        ..color = isGrey ? Colors.grey : segmentColor
        ..strokeWidth = lineWidth;

      // Draw line segment (solid for Google Maps style)
      // Only draw solid line if both origin AND destination are selected
      if (originIndex != null &&
          destinationIndex != null &&
          (i >= (originIndex ?? -1) && i < (destinationIndex ?? -1) ||
              i >= (destinationIndex ?? -1) && i < (originIndex ?? -1))) {
        // Draw solid line for active route segment
        canvas.drawLine(
          Offset(x, yStart),
          Offset(x, yEnd),
          paint..strokeWidth = 3.5,
        );
      } else {
        // Draw dashed line for inactive segments or when destination is unselected
        double currentY = yStart;
        while (currentY < yEnd) {
          final dashEnd = (currentY + dashHeight).clamp(currentY, yEnd);
          canvas.drawLine(Offset(x, currentY), Offset(x, dashEnd), paint);
          currentY += dashHeight + dashSpace;
        }
      }
    }

    // Draw circles
    final circleRadius = 7.0;
    for (int i = 0; i < stopCount; i++) {
      final cy = rowHeight / 2 + i * rowHeight;

      // Determine circle appearance
      final isOrigin = originIndex != null && i == originIndex;
      final isDestination = destinationIndex != null && i == destinationIndex;
      final isGreyed =
          greyedStops != null &&
          greyedStops!.contains(i) &&
          !isOrigin &&
          !isDestination;

      if (isOrigin || isDestination) {
        // Draw shadow
        canvas.drawCircle(
          Offset(x, cy),
          circleRadius + 3,
          Paint()
            ..color = Colors.black
                .withAlpha(51) // 0.2 opacity = 51 alpha
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3),
        );

        // White outer circle
        canvas.drawCircle(
          Offset(x, cy),
          circleRadius + 2,
          Paint()..color = Colors.white,
        );

        // Colored inner circle (green for origin, red for destination)
        canvas.drawCircle(
          Offset(x, cy),
          circleRadius - 2,
          Paint()
            ..color = isOrigin
                ? Color(0xFF0F9D58)
                : Color(0xFFDB4437), // Google Maps colors
        );
      } else {
        // Regular stop circle
        // Fill
        canvas.drawCircle(
          Offset(x, cy),
          circleRadius,
          Paint()..color = Colors.white,
        );

        // Border
        canvas.drawCircle(
          Offset(x, cy),
          circleRadius,
          Paint()
            ..color = isGreyed
                ? Colors.grey
                : Color(0xFF4285F4) // Use Google Maps blue
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// A widget that wraps the RouteLineWithStopsPainter for convenience
class RouteLineWithStops extends StatelessWidget {
  final int stopCount;
  final double rowHeight;
  final double lineWidth;
  final int? originIndex;
  final int? destinationIndex;
  final List<int>? greyedStops;
  final Color lineColor;

  const RouteLineWithStops({
    super.key,
    required this.stopCount,
    this.rowHeight = 28,
    this.lineWidth = 2,
    this.originIndex,
    this.destinationIndex,
    this.greyedStops,
    this.lineColor = Colors.blueGrey,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(28, stopCount * rowHeight),
      painter: RouteLineWithStopsPainter(
        stopCount: stopCount,
        rowHeight: rowHeight,
        lineWidth: lineWidth,
        originIndex: originIndex,
        destinationIndex: destinationIndex,
        greyedStops: greyedStops,
        lineColor: lineColor,
      ),
    );
  }
}
