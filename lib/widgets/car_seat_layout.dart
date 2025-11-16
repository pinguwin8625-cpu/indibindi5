import 'package:flutter/material.dart';
import 'dart:io';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';

enum SeatStatus { available, occupied, driver }

class CarLayoutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw car outline (rounded rectangle)
    final carRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(10, 10, size.width - 20, size.height - 20),
      Radius.circular(15),
    );
    canvas.drawRRect(carRect, paint);

    // Draw windshield (top arc)
    final windshieldRect = Rect.fromLTWH(30, 15, size.width - 60, 40);
    canvas.drawArc(windshieldRect, 0, 3.14159, false, paint);

    // Draw rear window (bottom arc)
    final rearRect = Rect.fromLTWH(30, size.height - 55, size.width - 60, 40);
    canvas.drawArc(rearRect, 0, 3.14159, false, paint);

    // Draw doors (side rectangles)
    // Left door
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(15, 60, 40, 120),
        Radius.circular(8),
      ),
      paint,
    );

    // Right door
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - 55, 60, 40, 120),
        Radius.circular(8),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SteeringWheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = 12.0; // 24px diameter = 12px radius

    // Create a path for the ring (area between outer and inner circles)
    final path = Path()
      ..addOval(Rect.fromCircle(center: center, radius: outerRadius))
      ..addOval(Rect.fromCircle(center: center, radius: innerRadius));
    
    // Set fill rule to even-odd to create a hole in the center
    path.fillType = PathFillType.evenOdd;
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}



class CarSeatLayout extends StatefulWidget {
  final String userRole; // 'Driver' or 'Rider'
  final Function(List<int>) onSeatsSelected;
  final bool isDisabled;

  const CarSeatLayout({
    super.key,
    required this.userRole,
    required this.onSeatsSelected,
    this.isDisabled = false,
  });

  @override
  State<CarSeatLayout> createState() => _CarSeatLayoutState();
}

class _CarSeatLayoutState extends State<CarSeatLayout> {
  // Car layout: 4 rider seats (excluding driver) - Total 5 seats
  // Rotated 90°, car faces right:
  // Front: [Driver]    Back: [Seat2]
  //        [Seat1]           [Seat3]
  //                          [Seat4]

  List<SeatStatus> seatStatuses = [
    SeatStatus.available, // Seat 1 (front rider)
    SeatStatus.available, // Seat 2 (back left)
    SeatStatus.available, // Seat 3 (back center)
    SeatStatus.available, // Seat 4 (back right)
  ];

  List<int> selectedSeats = [];
  
  @override
  void initState() {
    super.initState();
    // For drivers, all 4 passenger seats are available by default
    if (widget.userRole.toLowerCase() == 'driver') {
      selectedSeats = [0, 1, 2, 3];
      // Notify parent widget
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onSeatsSelected(selectedSeats);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Simple car layout with 3 aligned rows - bigger for labeling space
            Container(
              width: 577, // Increased from 575 to 577 (2px more)
              height: 420,
              decoration: BoxDecoration(),
              child: Stack(
                children: [
                  // Seat arrangement in 3 aligned rows
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 10,
                        ),
                        child: Container(
                          decoration: BoxDecoration(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // LEFT COLUMN - Back seats (rear left, center, rear right)
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center, // Changed from spaceEvenly to center
                                children: [
                                  // Seat 2 with label
                                  Column(
                                    children: [
                                      _buildSeat(
                                        status: seatStatuses[1],
                                        label: '',
                                        onTap: widget.isDisabled ? null : () => _toggleSeat(1),
                                      ),
                                      SizedBox(height: 4),
                                      _buildSeatLabel('${l10n.passenger}-2'),
                                    ],
                                  ),
                                  SizedBox(height: 5), // 5px spacing between seats
                                  // Seat 3 with label
                                  Column(
                                    children: [
                                      _buildSeat(
                                        status: seatStatuses[2],
                                        label: '',
                                        onTap: widget.isDisabled ? null : () => _toggleSeat(2),
                                      ),
                                      SizedBox(height: 4),
                                      _buildSeatLabel('${l10n.passenger}-3'),
                                    ],
                                  ),
                                  SizedBox(height: 5), // 5px spacing between seats
                                  // Seat 4 with label
                                  Column(
                                    children: [
                                      _buildSeat(
                                        status: seatStatuses[3],
                                        label: '',
                                        onTap: widget.isDisabled ? null : () => _toggleSeat(3),
                                      ),
                                      SizedBox(height: 4),
                                      _buildSeatLabel('${l10n.passenger}-4'),
                                    ],
                                  ),
                                ],
                              ),

                              // RIGHT COLUMN - Front seats (driver and front rider) - moved further left
                              Padding(
                                padding: EdgeInsets.only(right: 40), // Move front seats 40px left (was 20px)
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                  // Driver seat with info
                                  Column(
                                    children: [
                                      _buildSeat(
                                        status: SeatStatus.driver,
                                        label: '',
                                        onTap: null,
                                      ),
                                      SizedBox(height: 4),
                                      _buildDriverLabel(),
                                    ],
                                  ),

                                  // Front rider seat with label
                                  Column(
                                    children: [
                                      _buildSeat(
                                        status: seatStatuses[0],
                                        label: '',
                                        onTap: widget.isDisabled ? null : () => _toggleSeat(0),
                                      ),
                                      SizedBox(height: 4),
                                      _buildSeatLabel('${l10n.passenger}-1'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Steering wheel positioned to the right of driver seat
                  Positioned(
                    right: 8, // Moved further right to align with seats moved left (was 28)
                    top: 90, // Vertically centered with the driver seat
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(1.047198), // 60 degrees in radians (45 + 15)
                      child: CustomPaint(
                        size: Size(40, 40),
                        painter: SteeringWheelPainter(),
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Center(
                            child: Icon(
                              Icons.add,
                              color: Colors.black,
                              size: 42,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 30px horizontal line to the right of steering wheel
                  Positioned(
                    right: -9, // Adjusted to align with new steering wheel position (was 11)
                    top: 109, // Vertically center with wheel (90 + 20 - 1 = 109)
                    child: Container(
                      width: 25,
                      height: 4,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeat({
    required SeatStatus status,
    required String label,
    required VoidCallback? onTap,
  }) {
    Color backgroundColor;
    Color borderColor;

    switch (status) {
      case SeatStatus.available:
        backgroundColor = Colors.green[100]!;
        borderColor = Color(0xFF00C853); // Standard green border
        break;
      case SeatStatus.occupied:
        backgroundColor = Colors.red[100]!; // Red background for unavailable seats
        borderColor = Color(0xFFDD2C00); // Standard red border
        break;
      case SeatStatus.driver:
        backgroundColor = Colors.red[100]!; // Red background like unavailable
        borderColor = Color(0xFFDD2C00); // Standard red border
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(
                20,
              ), // Rounded square instead of circle - doubled radius
              border: Border.all(color: borderColor, width: 2),
            ),
            child: status == SeatStatus.driver
                ? _buildDriverProfilePhoto()
                : Icon(Icons.person, size: 40, color: Colors.grey[700]),
          ),

          // Dynamic bullet point for drivers only (not on driver's own seat)
          if (status != SeatStatus.driver && widget.userRole.toLowerCase() == 'driver')
            Positioned(
              left: 2,
              top: 2,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _getSeatIconColor(status),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: _getSeatIcon(status),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDriverProfilePhoto() {
    final currentUser = AuthService.currentUser;
    
    // Check if user has a local profile photo
    if (currentUser?.profilePhotoUrl != null && currentUser!.profilePhotoUrl!.isNotEmpty) {
      final photoFile = File(currentUser.profilePhotoUrl!);
      if (photoFile.existsSync()) {
        return Container(
          width: 76,
          height: 76,
          margin: EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.file(
            photoFile,
            fit: BoxFit.cover,
          ),
        );
      }
    }
    
    // Default placeholder icon
    return Container(
      width: 76,
      height: 76,
      margin: EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Color(0xFFBDBDBD),
      ),
      child: Icon(
        Icons.person,
        size: 40,
        color: Colors.grey[700],
      ),
    );
  }

  void _toggleSeat(int seatIndex) {
    setState(() {
      if (widget.userRole.toLowerCase() == 'driver') {
        // Drivers can only remove seats from availability
        if (selectedSeats.contains(seatIndex)) {
          selectedSeats.remove(seatIndex);
          seatStatuses[seatIndex] = SeatStatus.occupied;
        } else {
          // Add back to available
          selectedSeats.add(seatIndex);
          seatStatuses[seatIndex] = SeatStatus.available;
        }
      } else {
        // Riders can add seats to their selection
        if (seatStatuses[seatIndex] == SeatStatus.available) {
          seatStatuses[seatIndex] = SeatStatus.occupied;
          if (!selectedSeats.contains(seatIndex)) {
            selectedSeats.add(seatIndex);
          }
        } else if (seatStatuses[seatIndex] == SeatStatus.occupied) {
          seatStatuses[seatIndex] = SeatStatus.available;
          selectedSeats.remove(seatIndex);
        }
      }

      widget.onSeatsSelected(selectedSeats);
    });
  }
  
  Color _getSeatIconColor(SeatStatus status) {
    if (widget.userRole.toLowerCase() == 'driver') {
      // For drivers: available seats show minus (red), occupied seats show plus (green)
      return status == SeatStatus.available 
          ? Colors.red 
          : Color(0xFF00C853);
    } else {
      // For riders: available seats show plus (green), occupied seats show minus (red)
      return status == SeatStatus.available 
          ? Color(0xFF00C853)
          : Colors.red;
    }
  }
  
  Widget _getSeatIcon(SeatStatus status) {
    bool showMinus;
    if (widget.userRole.toLowerCase() == 'driver') {
      // For drivers: available seats show minus (to remove), occupied seats show plus (to add back)
      showMinus = status == SeatStatus.available;
    } else {
      // For riders: occupied seats show minus (to deselect), available seats show plus (to select)
      showMinus = status == SeatStatus.occupied;
    }
    
    if (showMinus) {
      return Container(
        // Minus sign
        width: 12,
        height: 3,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(2),
        ),
      );
    } else {
      return Icon(
        // Plus sign
        Icons.add,
        color: Colors.white,
        size: 16,
      );
    }
  }

  Widget _buildSeatLabel(String name) {
    return Text(
      name,
      style: TextStyle(
        color: Color(0xFF2E2E2E),
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    );
  }

  Widget _buildDriverLabel() {
    final currentUser = AuthService.currentUser;
    final l10n = AppLocalizations.of(context)!;
    
    // If driver is the current user, show their name with last initial
    if (widget.userRole.toLowerCase() == l10n.driver.toLowerCase() && currentUser != null) {
      String displayName = currentUser.name;
      if (currentUser.surname.isNotEmpty) {
        displayName = '${currentUser.name} ${currentUser.surname[0]}.';
      }
      
      return Text(
        displayName,
        style: TextStyle(
          color: Color(0xFF2E2E2E),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      );
    }
    
    // Default label for non-current-user drivers
    return _buildSeatLabel(l10n.driver);
  }
}
