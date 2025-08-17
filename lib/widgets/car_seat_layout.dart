import 'package:flutter/material.dart';

enum SeatStatus {
  available,
  occupied,
  driver,
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
              width: 220,
              height: 200,
              child: Stack(
              children: [
                // Driver seat (top right - front left when car faces right)
                Positioned(
                  top: 10,
                  right: 10,
                  child: _buildSeat(
                    status: SeatStatus.driver,
                    label: '',
                    onTap: null,
                  ),
                ),
                
                // Front passenger seat (bottom right - front right when car faces right)
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: _buildSeat(
                    status: seatStatuses[0],
                    label: '',
                    onTap: () => _toggleSeat(0),
                  ),
                ),
                
                // Back left seat (top left)
                Positioned(
                  top: 5,
                  left: 10,
                  child: _buildSeat(
                    status: seatStatuses[1],
                    label: '',
                    onTap: () => _toggleSeat(1),
                  ),
                ),
                
                // Back center seat (center left)
                Positioned(
                  top: 72,
                  left: 10,
                  child: _buildSeat(
                    status: seatStatuses[2],
                    label: '',
                    onTap: () => _toggleSeat(2),
                  ),
                ),
                
                // Back right seat (bottom left)
                Positioned(
                  bottom: 5,
                  left: 10,
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
        backgroundColor = Colors.red[100]!;
        borderColor = Colors.red[600]!;
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
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Icon(
          Icons.person,
          size: 24,
          color: borderColor,
        ),
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
