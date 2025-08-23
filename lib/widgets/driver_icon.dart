import 'package:flutter/material.dart';

class DriverIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const DriverIcon({super.key, this.size = 24.0, this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: DriverIconPainter(color: color ?? Colors.white),
    );
  }
}

class DriverIconPainter extends CustomPainter {
  final Color color;

  DriverIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08;

    // Draw person's head (circle) - made more prominent
    final headPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.22),
      size.width * 0.18,
      headPaint,
    );

    // Add head outline for definition
    final headOutlinePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06;

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.22),
      size.width * 0.18,
      headOutlinePaint,
    );

    // Draw person's body (simplified)
    final bodyPath = Path();
    bodyPath.moveTo(size.width * 0.35, size.height * 0.4);
    bodyPath.lineTo(size.width * 0.35, size.height * 0.7);
    bodyPath.moveTo(size.width * 0.65, size.height * 0.4);
    bodyPath.lineTo(size.width * 0.65, size.height * 0.7);
    canvas.drawPath(bodyPath, paint);

    // Draw steering wheel (quarter circle arc)
    final wheelPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06;

    // Steering wheel arc (quarter circle)
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.8),
        width: size.width * 0.6,
        height: size.width * 0.6,
      ),
      -3.14159 * 0.25, // Start angle (top-left quarter)
      3.14159 * 0.5, // Sweep angle (half circle)
      false,
      wheelPaint,
    );

    // Draw hands holding the steering wheel
    final handPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.05;

    // Left hand
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.6),
      Offset(size.width * 0.35, size.height * 0.75),
      handPaint,
    );

    // Right hand
    canvas.drawLine(
      Offset(size.width * 0.65, size.height * 0.6),
      Offset(size.width * 0.65, size.height * 0.75),
      handPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
