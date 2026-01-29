import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../l10n/app_localizations.dart';
import '../utils/date_time_helpers.dart';

/// Shared booking card widget used across My Bookings and Admin Panel
/// Ensures consistent display of booking information
class BookingCard extends StatefulWidget {
  final Booking booking;
  final bool isPast;
  final bool isCanceled;
  final bool isOngoing;
  final bool isArchived;
  final VoidCallback? onCancel;
  final Widget Function(List<int>, Booking) buildMiniatureSeatLayout;
  final bool showActions; // Whether to show cancel/archive buttons
  final bool showSeatsForCanceled; // Whether to show seat layout for canceled rides (admin only)
  final bool isCollapsible; // Whether the card can be collapsed/expanded
  final bool initiallyExpanded; // Initial expansion state when collapsible

  const BookingCard({
    super.key,
    required this.booking,
    required this.isPast,
    required this.isCanceled,
    this.isOngoing = false,
    this.isArchived = false,
    this.onCancel,
    required this.buildMiniatureSeatLayout,
    this.showActions = true,
    this.showSeatsForCanceled = false,
    this.isCollapsible = false,
    this.initiallyExpanded = false,
  });

  @override
  State<BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    // Non-collapsible cards are always expanded
    // Collapsible cards use initiallyExpanded parameter
    if (!widget.isCollapsible) {
      _isExpanded = true;
    } else {
      _isExpanded = widget.initiallyExpanded;
    }
  }

  String _formatDate(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diffDays = target.difference(today).inDays;

    if (diffDays == 0) return l10n.today;
    if (diffDays == 1) return l10n.tomorrow;

    final monthAbbr = [
      l10n.jan,
      l10n.feb,
      l10n.mar,
      l10n.apr,
      l10n.may,
      l10n.jun,
      l10n.jul,
      l10n.aug,
      l10n.sep,
      l10n.oct,
      l10n.nov,
      l10n.dec,
    ];

    return '${date.day} ${monthAbbr[date.month - 1]}';
  }

  // Get status suffix (Hidden) based on time since arrival
  // Completed: visible for 7 days, then hidden
  // Canceled: visible for 1 day, then hidden
  String _getStatusSuffix() {
    final now = DateTime.now();
    final arrivalTime = widget.booking.arrivalTime;

    // Different cutoff for canceled vs completed
    final hideCutoff = widget.isCanceled
        ? arrivalTime.add(Duration(days: 1))
        : arrivalTime.add(Duration(days: 7));

    if (now.isAfter(hideCutoff)) {
      return ' (Hidden)';
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Debug: Log archived booking label info
    if (kDebugMode && widget.isArchived) {
      print('🏷️ BookingCard: Archived booking ${widget.booking.id}');
      print('🏷️ BookingCard: isAutoArchived=${widget.booking.isAutoArchived}, label will be: ${widget.booking.isAutoArchived == true ? "Auto-archived" : "Archived"}');
    }

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: widget.isCollapsible
            ? () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Status note (at very top) - always show status label
                Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: widget.isArchived
                          ? Colors.grey.withOpacity(0.1)
                          : widget.isCanceled
                              ? Colors.red.withOpacity(0.1)
                              : widget.isOngoing
                                  ? Colors.orange.withOpacity(0.1)
                                  : (widget.isPast ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: widget.isArchived
                          ? RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                children: [
                                  TextSpan(
                                    text: widget.booking.isAutoArchived == true ? l10n.autoArchived : l10n.userArchived,
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  TextSpan(
                                    text: ' (${widget.isCanceled ? l10n.canceled : l10n.completed})',
                                    style: TextStyle(color: widget.isCanceled ? Colors.red[700] : Colors.green[700]),
                                  ),
                                ],
                              ),
                            )
                          : Text(
                              (widget.isCanceled
                                  ? l10n.canceled
                                  : widget.isOngoing
                                      ? l10n.ongoing
                                      : (widget.isPast ? l10n.completed : l10n.upcoming)) + _getStatusSuffix(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: widget.isCanceled
                                    ? Colors.red[700]
                                    : widget.isOngoing
                                        ? Colors.orange[700]
                                        : (widget.isPast ? Colors.green[700] : Colors.blue[700]),
                              ),
                            ),
                    ),
                  ),
                ),

                // Route name and date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.booking.route.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E2E2E),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    SizedBox(
                      width: 85,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _formatDate(context, widget.booking.departureTime),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Origin with departure time - simple inline design (always visible)
                Row(
                  children: [
                    // Green circle marker
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8),
                    // Time
                    Text(
                      formatTimeHHmm(widget.booking.departureTime),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                    ),
                    SizedBox(width: 8),
                    // Stop name
                    Expanded(
                      child: Text(
                        widget.booking.originName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2E2E2E),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8),

                // Destination with arrival time - simple inline design (always visible)
                Row(
                  children: [
                    // Red circle marker
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8),
                    // Time with +1 indicator if needed
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formatTimeHHmm(widget.booking.arrivalTime),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.red[700],
                          ),
                        ),
                        // Show +1 if arrival is on a different day
                        if (widget.booking.arrivalTime.day != widget.booking.departureTime.day ||
                            widget.booking.arrivalTime.month != widget.booking.departureTime.month ||
                            widget.booking.arrivalTime.year != widget.booking.departureTime.year)
                          Padding(
                            padding: EdgeInsets.only(left: 2),
                            child: Text(
                              '+1',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[400],
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(width: 8),
                    // Stop name
                    Expanded(
                      child: Text(
                        widget.booking.destinationName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2E2E2E),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Show seat layout only if expanded
                if (_isExpanded) ...[
                  // Miniature seat layout
                  // Hide seats entirely for canceled bookings (unless admin panel)
                  if (!widget.isCanceled || widget.showSeatsForCanceled) ...[
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Miniature seat layout - always show for all bookings
                        Expanded(
                          child: widget.buildMiniatureSeatLayout(
                            widget.booking.selectedSeats,
                            widget.booking,
                          ),
                        ),

                        // Status button/label in bottom right - removed, now at bottom of card
                        SizedBox.shrink(),
                      ],
                    ),

                  ], // End of seat layout section
                ], // End of _isExpanded section

                // Cancel button at the bottom (only for upcoming rides)
                if (_isExpanded && widget.showActions && !widget.isOngoing && !widget.isArchived && !widget.isCanceled && !widget.isPast)
                  Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: widget.onCancel,
                        icon: Icon(Icons.close, size: 18),
                        label: Text(l10n.cancelRide),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red[600],
                          side: BorderSide(color: Colors.red[300]!),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
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
}
