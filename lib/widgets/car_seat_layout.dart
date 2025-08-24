import 'package:flutter/material.dart';

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

class CarSeatLayout extends StatefulWidget {
  final String userRole; // 'Driver' or 'Rider'
  final Function(List<int>) onSeatsSelected;

  const CarSeatLayout({
    super.key,
    required this.userRole,
    required this.onSeatsSelected,
  });

  @override
  State<CarSeatLayout> createState() => _CarSeatLayoutState();
}

class _CarSeatLayoutState extends State<CarSeatLayout> {
  // Car layout: 4 passenger seats (excluding driver) - Total 5 seats
  // Rotated 90°, car faces right:
  // Front: [Driver]    Back: [Seat2]
  //        [Seat1]           [Seat3]
  //                          [Seat4]

  List<SeatStatus> seatStatuses = [
    SeatStatus.available, // Seat 1 (front passenger)
    SeatStatus.available, // Seat 2 (back left)
    SeatStatus.available, // Seat 3 (back center)
    SeatStatus.available, // Seat 4 (back right)
  ];

  List<int> selectedSeats = [];

  @override
  Widget build(BuildContext context) {
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
              width: 550,
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Seat 2 with label
                              Column(
                                children: [
                                  _buildSeat(
                                    status: seatStatuses[1],
                                    label: '',
                                    onTap: () => _toggleSeat(1),
                                  ),
                                  SizedBox(height: 4),
                                  _buildSeatLabel('Passenger-1', '4.6'),
                                ],
                              ),
                              // Seat 3 with label
                              Column(
                                children: [
                                  _buildSeat(
                                    status: seatStatuses[2],
                                    label: '',
                                    onTap: () => _toggleSeat(2),
                                  ),
                                  SizedBox(height: 4),
                                  _buildSeatLabel('Passenger-2', '4.9'),
                                ],
                              ),
                              // Seat 4 with label
                              Column(
                                children: [
                                  _buildSeat(
                                    status: seatStatuses[3],
                                    label: '',
                                    onTap: () => _toggleSeat(3),
                                  ),
                                  SizedBox(height: 4),
                                  _buildSeatLabel('Passenger-3', '4.7'),
                                ],
                              ),
                            ],
                          ),

                          // RIGHT COLUMN - Front seats (driver and front passenger)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                  _buildSeatLabel('Driver', '4.8'),
                                ],
                              ),

                              // Front passenger seat with label
                              Column(
                                children: [
                                  _buildSeat(
                                    status: seatStatuses[0],
                                    label: '',
                                    onTap: () => _toggleSeat(0),
                                  ),
                                  SizedBox(height: 4),
                                  _buildSeatLabel('Passenger-4', '4.5'),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                        ),
                      ),
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
        borderColor = Colors.transparent;
        break;
      case SeatStatus.occupied:
        backgroundColor = Colors.grey[300]!;
        borderColor = Colors.transparent;
        break;
      case SeatStatus.driver:
        backgroundColor = Colors.grey[300]!;
        borderColor = Colors.transparent;
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
              border: Border.all(color: borderColor, width: 0),
            ),
            child: status == SeatStatus.driver
                ? _buildDriverProfilePhoto()
                : Icon(Icons.person, size: 40, color: Colors.grey[700]),
          ),

          // Red bullet point with minus symbol for non-driver seats
          if (status != SeatStatus.driver)
            Positioned(
              left: 2,
              top: 2,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 12,
                    height: 3,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDriverProfilePhoto() {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          8,
        ), // Rounded square to match seat shape
        color: Color(0xFFBDBDBD), // Solid grey to indicate not available
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        'https://randomuser.me/api/portraits/men/1.jpg',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Container(color: Color(0xFFBDBDBD)),
      ),
    );
  }

  void _toggleSeat(int seatIndex) {
    setState(() {
      // Both drivers and riders can toggle seats between available/occupied
      if (seatStatuses[seatIndex] == SeatStatus.available) {
        seatStatuses[seatIndex] = SeatStatus.occupied;
        if (!selectedSeats.contains(seatIndex)) {
          selectedSeats.add(seatIndex);
        }
      } else if (seatStatuses[seatIndex] == SeatStatus.occupied) {
        seatStatuses[seatIndex] = SeatStatus.available;
        selectedSeats.remove(seatIndex);
      }

      widget.onSeatsSelected(selectedSeats);
    });
  }

  Widget _buildSeatLabel(String name, String rating) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            name,
            style: TextStyle(
              color: Color(0xFF2E2E2E),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          SizedBox(width: 6),
          Icon(Icons.star, color: Colors.amber, size: 11),
          SizedBox(width: 2),
          Text(
            rating,
            style: TextStyle(
              color: Color(0xFF2E2E2E),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
