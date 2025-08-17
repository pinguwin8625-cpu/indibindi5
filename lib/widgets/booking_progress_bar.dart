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
      height: 30, // Increased height to accommodate larger markers
      child: Stack(
        children: [
          // Origin marker (start point - Google Maps style pin marker)
          Positioned(
            left: 0,
            top: 2,
            child: CustomPaint(
              size: Size(16, 20),
              painter: GoogleMapsOriginPinPainter(),
            ),
          ),
          // Destination marker (end point - Google Maps style pin marker)
          Positioned(
            right: 0,
            top: 2,
            child: CustomPaint(
              size: Size(16, 20),
              painter: GoogleMapsDestinationPinPainter(),
            ),
          ),
          // Background track (full width)
          Positioned(
            top: 20,
            left: 8, // Offset to center between origin and destination markers
            right: 8,
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
              top: 20,
              left: 8, // Offset to match background track
              child: Container(
                width: (progress * (MediaQuery.of(context).size.width - 48)), // Adjusted for marker offsets
                height: 2,
                decoration: BoxDecoration(
                  color: Colors.red[600],
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          
          // Step markers along the progress line
          ...List.generate(totalSteps - 1, (index) {
            double stepProgress = (index + 1) / totalSteps;
            double stepPosition = 8 + (stepProgress * (MediaQuery.of(context).size.width - 48));
            bool isCompleted = currentStep > index + 1;
            
            return Positioned(
              left: stepPosition - 4, // Center the 8px marker
              top: 16,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.red[600] : Colors.grey[400],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 1,
                      spreadRadius: 0.5,
                      offset: Offset(0, 0.5),
                    ),
                  ],
                ),
              ),
            );
          }),
          // Big red car icon (custom side view, heading right) - stops before destination
          AnimatedPositioned(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            left: progress > 0 ? (progress * (MediaQuery.of(context).size.width - 48 - 24)) + 8 : 8, // Stop 24px before destination marker
            top: 7,
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

// Google Maps style origin pin painter (green)
class GoogleMapsOriginPinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF00C853)
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2);

    // Draw shadow first
    final shadowPath = _createPinPath(size, 1, 1);
    canvas.drawPath(shadowPath, shadowPaint);

    // Draw main pin
    final pinPath = _createPinPath(size, 0, 0);
    canvas.drawPath(pinPath, paint);

    // Draw white center circle
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.35),
      size.width * 0.2,
      centerPaint,
    );
  }

  Path _createPinPath(Size size, double offsetX, double offsetY) {
    final path = Path();
    final centerX = size.width / 2 + offsetX;
    final centerY = size.height * 0.35 + offsetY;
    final radius = size.width * 0.35;

    // Create teardrop shape
    path.addOval(Rect.fromCircle(center: Offset(centerX, centerY), radius: radius));
    
    // Add the point at the bottom
    path.moveTo(centerX, centerY + radius);
    path.lineTo(centerX, size.height + offsetY);
    path.lineTo(centerX - radius * 0.3, centerY + radius * 0.7);
    path.close();

    return path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Google Maps style destination flag painter (red flag)
class GoogleMapsDestinationPinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final flagPaint = Paint()
      ..color = Color(0xFFDD2C00)
      ..style = PaintingStyle.fill;

    final polePaint = Paint()
      ..color = Colors.grey[600]!
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1);

    // Draw shadow for pole
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.47 + 1, 1, size.width * 0.06, size.height),
      shadowPaint,
    );

    // Draw flag pole (vertical line)
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.47, 0, size.width * 0.06, size.height),
      polePaint,
    );

    // Draw shadow for flag
    final flagShadowPath = Path();
    flagShadowPath.moveTo(size.width * 0.53 + 1, size.height * 0.1 + 1);
    flagShadowPath.lineTo(size.width * 0.9 + 1, size.height * 0.2 + 1);
    flagShadowPath.lineTo(size.width * 0.85 + 1, size.height * 0.35 + 1);
    flagShadowPath.lineTo(size.width * 0.9 + 1, size.height * 0.5 + 1);
    flagShadowPath.lineTo(size.width * 0.53 + 1, size.height * 0.6 + 1);
    flagShadowPath.close();
    canvas.drawPath(flagShadowPath, shadowPaint);

    // Draw flag (triangular pennant shape)
    final flagPath = Path();
    flagPath.moveTo(size.width * 0.53, size.height * 0.1);
    flagPath.lineTo(size.width * 0.9, size.height * 0.2);
    flagPath.lineTo(size.width * 0.85, size.height * 0.35);
    flagPath.lineTo(size.width * 0.9, size.height * 0.5);
    flagPath.lineTo(size.width * 0.53, size.height * 0.6);
    flagPath.close();
    canvas.drawPath(flagPath, flagPaint);

    // Add a small white highlight on the flag
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final highlightPath = Path();
    highlightPath.moveTo(size.width * 0.53, size.height * 0.1);
    highlightPath.lineTo(size.width * 0.75, size.height * 0.15);
    highlightPath.lineTo(size.width * 0.7, size.height * 0.25);
    highlightPath.lineTo(size.width * 0.53, size.height * 0.35);
    highlightPath.close();
    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
