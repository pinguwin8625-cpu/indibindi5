import 'package:flutter/material.dart';

enum SeatStatus { available, occupied, driver }

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
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Simple car layout (car facing right)
            SizedBox(
              width: 240,
              height: 240,
              child: Stack(
                children: [
                  // Driver seat (top right - front left when car faces right)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Column(
                      children: [
                        _buildSeat(
                          status: SeatStatus.driver,
                          label: '',
                          onTap: null,
                        ),
                        SizedBox(height: 2),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 1,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Mike A.',
                                style: TextStyle(
                                  color: Color(0xFF2E2E2E),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                              SizedBox(height: 2),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 12,
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    '4.8',
                                    style: TextStyle(
                                      color: Color(0xFF2E2E2E),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Front passenger seat (bottom right - front right when car faces right)
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: _buildSeat(
                      status: seatStatuses[0],
                      label: '',
                      onTap: () => _toggleSeat(0),
                    ),
                  ),

                  // Back left seat (top left)
                  Positioned(
                    top: 5,
                    left: 5,
                    child: _buildSeat(
                      status: seatStatuses[1],
                      label: '',
                      onTap: () => _toggleSeat(1),
                    ),
                  ),

                  // Back center seat (center left)
                  Positioned(
                    top: 92,
                    left: 5,
                    child: _buildSeat(
                      status: seatStatuses[2],
                      label: '',
                      onTap: () => _toggleSeat(2),
                    ),
                  ),

                  // Back right seat (bottom left)
                  Positioned(
                    bottom: 5,
                    left: 5,
                    child: _buildSeat(
                      status: seatStatuses[3],
                      label: '',
                      onTap: () => _toggleSeat(3),
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
        borderColor = Colors.green[600]!;
        break;
      case SeatStatus.occupied:
        backgroundColor = Colors.grey[300]!;
        borderColor = Colors.grey[600]!;
        break;
      case SeatStatus.driver:
        backgroundColor = Colors.grey[300]!;
        borderColor = Colors.grey[700]!;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(
            12,
          ), // Rounded square instead of circle
          border: Border.all(color: borderColor, width: 2),
        ),
        child: status == SeatStatus.driver
            ? _buildDriverProfilePhoto()
            : Icon(Icons.person, size: 24, color: borderColor),
      ),
    );
  }

  Widget _buildDriverProfilePhoto() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          10,
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
}
