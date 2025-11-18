import 'package:flutter/material.dart';
import '../models/routes.dart';
import '../models/booking.dart';
import '../services/booking_storage.dart';
import '../services/auth_service.dart';
import '../widgets/seat_planning_section_widget.dart';
import '../widgets/scroll_indicator.dart';
import '../widgets/booking_progress_bar.dart';
import '../utils/dialog_helper.dart';
import '../l10n/app_localizations.dart';

class RiderSeatSelectionScreen extends StatefulWidget {
  final RideInfo ride;

  const RiderSeatSelectionScreen({super.key, required this.ride});

  @override
  State<RiderSeatSelectionScreen> createState() =>
      _RiderSeatSelectionScreenState();
}

class _RiderSeatSelectionScreenState extends State<RiderSeatSelectionScreen> {
  List<int> selectedSeats = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Book a Ride',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
        iconTheme: IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4),
          child: BookingProgressBar(
            currentStep: 4, // Final step - seat selection
            totalSteps: 4,
          ),
        ),
      ),
      body: Column(
        children: [
          // Content
          Expanded(
            child: Column(
              children: [
                // Header with back button - same as driver's
                Container(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.arrow_back_ios, color: Color(0xFF8E8E8E), size: 20),
                        style: IconButton.styleFrom(backgroundColor: Colors.transparent, padding: EdgeInsets.all(8)),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.chooseYourSeat,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2E2E2E),
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 8),
                            // Seat count subtitle
                            Text(
                              l10n.seatsSelected(selectedSeats.length),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF8E8E8E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Scrollable content
                Expanded(
                  child: ScrollIndicator(
                    scrollController: _scrollController,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Car seat layout - same as driver's
                            SeatPlanningSectionWidget(
                        userRole: 'Rider',
                        selectedSeats: selectedSeats,
                        onSeatsSelected: (seats) {
                          setState(() {
                            selectedSeats = seats;
                          });
                        },
                        isDisabled: false,
                            ),

                            SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Fixed booking button at bottom - same as driver's
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
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
            ),
          ),
        ],
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

  Future<void> _confirmBooking() async {
    final currentUser = AuthService.currentUser;
    if (currentUser == null) return;
    
    final bookingStorage = BookingStorage();
    final l10n = AppLocalizations.of(context)!;
    
    // Find the driver's booking
    final driverBooking = bookingStorage.getAllBookings().firstWhere(
      (b) => b.id == widget.ride.id,
      orElse: () => throw Exception('Driver booking not found'),
    );
    
    // Create rider name (first name + last initial)
    String riderName = currentUser.name;
    if (currentUser.surname.isNotEmpty) {
      riderName = '${currentUser.name} ${currentUser.surname[0]}.';
    }
    
    // Create rider's own booking
    final riderBooking = Booking(
      id: '${widget.ride.id}_rider_${currentUser.id}',
      userId: currentUser.id,
      route: widget.ride.route,
      originIndex: widget.ride.originIndex,
      destinationIndex: widget.ride.destinationIndex,
      selectedSeats: selectedSeats,
      departureTime: widget.ride.departureTime,
      arrivalTime: widget.ride.departureTime.add(Duration(hours: 1)), // Estimate
      bookingDate: DateTime.now(),
      userRole: l10n.rider,
      driverName: widget.ride.driverName,
      driverRating: widget.ride.driverRating,
    );
    
    // Add rider's booking
    bookingStorage.addBooking(riderBooking);
    
    // Update driver's booking with rider info
    final updatedRiders = List<RiderInfo>.from(driverBooking.riders ?? []);
    for (final seatIndex in selectedSeats) {
      updatedRiders.add(RiderInfo(
        name: riderName,
        rating: currentUser.rating,
        seatIndex: seatIndex,
      ));
    }
    
    // Remove these seats from driver's available seats
    final updatedDriverSeats = List<int>.from(driverBooking.selectedSeats)
      ..removeWhere((seat) => selectedSeats.contains(seat));
    
    final updatedDriverBooking = driverBooking.copyWith(
      selectedSeats: updatedDriverSeats,
      riders: updatedRiders,
    );
    
    bookingStorage.updateBooking(updatedDriverBooking);
    
    print('✅ Rider booking created and driver booking updated');
    print('   Rider: $riderName, Seats: $selectedSeats');
    print('   Driver available seats now: $updatedDriverSeats');
    
    // Show confirmation dialog
    await DialogHelper.showInfoDialog(
      context: context,
      title: 'Booking Confirmed!',
      content: 'You have successfully booked ${selectedSeats.length} seat${selectedSeats.length > 1 ? 's' : ''} for the ride on ${_formatDateTime(widget.ride.departureTime)}.',
      okText: 'OK',
    );
    
    Navigator.of(context).pop(); // Go back to ride list
  }
}
