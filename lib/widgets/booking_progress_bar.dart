import 'package:flutter/material.dart';

class BookingProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const BookingProgressBar({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
  });

  @override
  Widget build(BuildContext context) {
    double progress = currentStep / totalSteps;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      height: 25,
      child: Stack(
        children: [
          // Background track (full width)
          Positioned(
            top: 15,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          // Red progress trail (follows behind the car)
          if (progress > 0)
            Positioned(
              top: 15,
              left: 0,
              child: Container(
                width: (progress * (MediaQuery.of(context).size.width - 32)),
                height: 2,
                decoration: BoxDecoration(
                  color: Colors.red[600],
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          // Big red car icon (custom side view, heading right)
          AnimatedPositioned(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            left: progress > 0 ? (progress * (MediaQuery.of(context).size.width - 32)) - 15 : 0,
            top: 2,
            child: CustomPaint(
              size: Size(30, 15),
              painter: SideViewCarPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class SideViewCarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red[600]!
      ..style = PaintingStyle.fill
      ..strokeWidth = 0;

    // Draw car as one continuous path
    final carPath = Path();
    
    // Start from back-left of car
    carPath.moveTo(size.width * 0.1, size.height * 0.8);
    
    // Bottom of car
    carPath.lineTo(size.width * 0.9, size.height * 0.8);
    
    // Front hood (slanted upward to right)
    carPath.lineTo(size.width, size.height * 0.6);
    carPath.lineTo(size.width, size.height * 0.4);
    
    // Top of main body
    carPath.lineTo(size.width * 0.8, size.height * 0.4);
    
    // Windshield
    carPath.lineTo(size.width * 0.7, size.height * 0.15);
    
    // Roof
    carPath.lineTo(size.width * 0.3, size.height * 0.15);
    
    // Rear windshield
    carPath.lineTo(size.width * 0.2, size.height * 0.4);
    
    // Back to start
    carPath.lineTo(size.width * 0.1, size.height * 0.4);
    carPath.close();
    
    // Draw the solid car body
    canvas.drawPath(carPath, paint);
    
    // Draw windows
    final windowPaint = Paint()
      ..color = Colors.lightBlue[100]!
      ..style = PaintingStyle.fill;
    
    // Front windshield window
    final frontWindowPath = Path();
    frontWindowPath.moveTo(size.width * 0.72, size.height * 0.38);
    frontWindowPath.lineTo(size.width * 0.68, size.height * 0.2);
    frontWindowPath.lineTo(size.width * 0.75, size.height * 0.2);
    frontWindowPath.lineTo(size.width * 0.78, size.height * 0.38);
    frontWindowPath.close();
    canvas.drawPath(frontWindowPath, windowPaint);
    
    // Side window
    final sideWindowPath = Path();
    sideWindowPath.moveTo(size.width * 0.4, size.height * 0.38);
    sideWindowPath.lineTo(size.width * 0.35, size.height * 0.22);
    sideWindowPath.lineTo(size.width * 0.62, size.height * 0.22);
    sideWindowPath.lineTo(size.width * 0.65, size.height * 0.38);
    sideWindowPath.close();
    canvas.drawPath(sideWindowPath, windowPaint);
    
    // Rear window
    final rearWindowPath = Path();
    rearWindowPath.moveTo(size.width * 0.22, size.height * 0.38);
    rearWindowPath.lineTo(size.width * 0.28, size.height * 0.2);
    rearWindowPath.lineTo(size.width * 0.32, size.height * 0.2);
    rearWindowPath.lineTo(size.width * 0.35, size.height * 0.38);
    rearWindowPath.close();
    canvas.drawPath(rearWindowPath, windowPaint);
    
    // Draw wheels as solid circles
    final wheelPaint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.fill;
    
    // Rear wheel
    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.8), 
      size.height * 0.1, 
      wheelPaint
    );
    
    // Front wheel
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.8), 
      size.height * 0.1, 
      wheelPaint
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
