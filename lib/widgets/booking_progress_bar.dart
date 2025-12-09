import 'package:flutter/material.dart';

class BookingProgressBar extends StatefulWidget {
  final int currentStep;
  final int totalSteps;

  const BookingProgressBar({
    super.key,
    required this.currentStep,
    this.totalSteps = 6,
  });

  @override
  State<BookingProgressBar> createState() => _BookingProgressBarState();
}

class _BookingProgressBarState extends State<BookingProgressBar>
    with TickerProviderStateMixin {
  AnimationController? _autoMoveController;

  @override
  void initState() {
    super.initState();
    _checkAndStartAutoMove();
  }

  @override
  void didUpdateWidget(BookingProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if we just entered step 5 (post a ride screen)
    if (widget.currentStep == 5 && oldWidget.currentStep != 5) {
      _startAutoMove();
    }
    // Check if we left step 5 (either completed or went back)
    else if (widget.currentStep != 5 && _autoMoveController != null) {
      _stopAutoMove();
      // Force rebuild to move car to final position immediately
      setState(() {});
    }
  }

  void _checkAndStartAutoMove() {
    if (widget.currentStep == 5) {
      // Delay to ensure widget is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startAutoMove();
      });
    }
  }

  void _startAutoMove() {
    _autoMoveController?.dispose();
    _autoMoveController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );
    
    _autoMoveController!.addListener(() {
      setState(() {});
    });
    
    // Loop the animation until ride is posted
    _autoMoveController!.repeat();
  }

  void _stopAutoMove() {
    _autoMoveController?.stop();
    _autoMoveController?.dispose();
    _autoMoveController = null;
  }

  @override
  void dispose() {
    _autoMoveController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trackWidth = MediaQuery.of(context).size.width - 48;
    final carPosition = _calculateCarPosition(context);
    // Red trail follows the car (car position + half car width to reach center of car)
    final redTrailWidth = carPosition - 8 + 15;

    return Container(
      margin: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 8,
      ), // No top margin - flush with top
      height:
          48, // Match Routes dropdown total height (16px container padding + ~32px DropdownButton)
      child: Stack(
        children: [
          // Origin marker (start point - location pin icon)
          Positioned(
            left: 0,
            top: 14, // Centered: (48 - 20) / 2 = 14
            child: Icon(Icons.location_on, color: Colors.green, size: 20),
          ),
          // Destination marker (end point - flag icon)
          Positioned(
            right: 0,
            top: 14, // Centered: (48 - 20) / 2 = 14
            child: Icon(Icons.flag, color: Colors.red, size: 20),
          ),
          // Background track (full width)
          Positioned(
            top: 32, // Centered below pins: 14 + 20 - 2 = 32
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
          if (redTrailWidth > 0)
            Positioned(
              top: 32, // Match background track position
              left: 8, // Offset to match background track
              child: Container(
                width: redTrailWidth.clamp(0, trackWidth),
                height: 2,
                decoration: BoxDecoration(
                  color: Colors.red[600],
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),

          // Step markers along the progress line
          ...List.generate(widget.totalSteps - 1, (index) {
            double stepProgress = (index + 1) / widget.totalSteps;
            double stepPosition =
                8 + (stepProgress * (MediaQuery.of(context).size.width - 48));
            // Dot is red if the car has passed it (car center position > dot position)
            bool isCompleted = (carPosition + 15) > stepPosition;

            return Positioned(
              left: stepPosition - 4, // Center the 8px marker
              top:
                  28, // Centered: 32 - 4 = 28 (track position - half marker height)
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.red[600] : Colors.grey[400],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
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
          Positioned(
            left: carPosition,
            top:
                19, // Centered: 32 - 13 = 19 (track position - half car height)
            child: CustomPaint(
              size: Size(30, 15),
              painter: SideViewCarPainter(),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateCarPosition(BuildContext context) {
    final trackWidth = MediaQuery.of(context).size.width - 48;
    final startPosition = 10.0;
    final endPosition = trackWidth - 30 + 10; // End position before flag
    
    double carPosition;
    
    if (widget.currentStep == 0) {
      carPosition = startPosition;
    } else if (widget.currentStep >= widget.totalSteps) {
      carPosition = endPosition;
    } else if (widget.currentStep == 5 && _autoMoveController != null) {
      // On "Post a Ride" screen - animate from step 5 position towards step 6
      double step5Progress = 5 / widget.totalSteps;
      double step5Position = 8 + (step5Progress * trackWidth) - 15;
      double step6Position = endPosition;
      
      // Interpolate between step 5 and step 6 based on animation
      double animValue = _autoMoveController!.value;
      carPosition = step5Position + (step6Position - step5Position) * animValue;
    } else {
      // Normal step-based positioning
      double stepProgress = widget.currentStep / widget.totalSteps;
      double stopPosition = 8 + (stepProgress * trackWidth);
      carPosition = stopPosition - 15; // 15 is half car width
    }

    return carPosition;
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
      wheelPaint,
    );

    // Front wheel
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.8),
      size.height * 0.1,
      wheelPaint,
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
      ..color =
          Color(0xFF2E2E2E) // Match dropdown background color
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
    path.addOval(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
    );

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
