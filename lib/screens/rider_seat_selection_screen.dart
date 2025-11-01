import 'package:flutter/material.dart';
import '../models/routes.dart';
import '../widgets/car_seat_layout.dart';

class RiderSeatSelectionScreen extends StatefulWidget {
  final RideInfo ride;

  const RiderSeatSelectionScreen({super.key, required this.ride});

  @override
  State<RiderSeatSelectionScreen> createState() =>
      _RiderSeatSelectionScreenState();
}

class _RiderSeatSelectionScreenState extends State<RiderSeatSelectionScreen> {
  List<int> selectedSeats = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Your Seats',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ride info card
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ride Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E2E2E),
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(
                              widget.ride.driverPhoto,
                            ),
                            backgroundColor: Colors.grey[300],
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.ride.driverName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E2E2E),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      widget.ride.driverRating.toString(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF2E2E2E),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Text(
                            widget.ride.price,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E2E2E),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Color(0xFF2E2E2E),
                          ),
                          SizedBox(width: 8),
                          Text(
                            _formatDateTime(widget.ride.departureTime),
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF2E2E2E),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.route, size: 16, color: Color(0xFF2E2E2E)),
                          SizedBox(width: 8),
                          Text(
                            '${widget.ride.route.stops[widget.ride.originIndex].name} → ${widget.ride.route.stops[widget.ride.destinationIndex].name}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF2E2E2E),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Seat selection
              Text(
                'Choose Your Seats',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E2E2E),
                ),
              ),
              Text(
                '${widget.ride.availableSeats} seats available',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),

              SizedBox(height: 16),

              // Car seat layout
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CarSeatLayout(
                  userRole: 'Rider',
                  onSeatsSelected: (seats) {
                    setState(() {
                      selectedSeats = seats;
                    });
                  },
                ),
              ),

              SizedBox(height: 24),

              // Confirm booking button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedSeats.isNotEmpty
                      ? () => _confirmBooking()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedSeats.isNotEmpty
                        ? Color(0xFF2E2E2E)
                        : Colors.grey[400],
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    selectedSeats.isEmpty
                        ? 'Select seats to continue'
                        : 'Confirm Booking (${selectedSeats.length} seat${selectedSeats.length > 1 ? 's' : ''})',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    String date =
        '${days[dateTime.weekday - 1]}, ${months[dateTime.month - 1]} ${dateTime.day}';
    String time = _formatTime(dateTime);

    return '$date at $time';
  }

  String _formatTime(DateTime time) {
    String hour = time.hour > 12 ? '${time.hour - 12}' : '${time.hour}';
    if (time.hour == 0) hour = '12';
    String minute = time.minute.toString().padLeft(2, '0');
    String period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  void _confirmBooking() {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Booking Confirmed!'),
          content: Text(
            'You have successfully booked ${selectedSeats.length} seat${selectedSeats.length > 1 ? 's' : ''} for the ride on ${_formatDateTime(widget.ride.departureTime)}.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to ride list
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
