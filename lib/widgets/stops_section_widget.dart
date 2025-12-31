import 'package:flutter/material.dart';
import '../models/routes.dart';
import '../screens/route_line_with_stops.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/messaging_service.dart';
import '../screens/chat_screen.dart';

class StopsSectionWidget extends StatefulWidget {
  final bool hideUnusedStops;
  final RouteInfo selectedRoute;
  final int? originIndex;
  final int? destinationIndex;
  final List<int> greyedStops;
  final Function(int?) onOriginChanged;
  final Function(int?) onDestinationChanged;
  final VoidCallback onResetDateTime;
  final bool isDisabled;
  final Function(bool)? onIntermediateExpandedChanged; // Callback when expanded state changes

  const StopsSectionWidget({
    super.key,
    required this.selectedRoute,
    required this.originIndex,
    required this.destinationIndex,
    required this.greyedStops,
    required this.onOriginChanged,
    required this.onDestinationChanged,
    required this.onResetDateTime,
    this.hideUnusedStops = false,
    this.isDisabled = false,
    this.onIntermediateExpandedChanged,
  });

  @override
  State<StopsSectionWidget> createState() => _StopsSectionWidgetState();
}

class _StopsSectionWidgetState extends State<StopsSectionWidget> {
  bool _showIntermediateStops = false;

  @override
  void didUpdateWidget(StopsSectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset expanded state when origin or destination changes
    if (oldWidget.originIndex != widget.originIndex ||
        oldWidget.destinationIndex != widget.destinationIndex) {
      _showIntermediateStops = false;
      widget.onIntermediateExpandedChanged?.call(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // When both origin and destination are selected, show compact view with all stops
    final bool showCompactView =
        widget.hideUnusedStops && widget.originIndex != null && widget.destinationIndex != null;

    // Get stops between origin and destination (inclusive)
    List<int> relevantStopIndices = [];
    int intermediateCount = 0;
    if (showCompactView) {
      for (int i = widget.originIndex!; i <= widget.destinationIndex!; i++) {
        relevantStopIndices.add(i);
      }
      intermediateCount = relevantStopIndices.length - 2; // Exclude origin and destination
    }

    // Row heights - compact needs to fit 26x26 markers for origin/destination
    final double compactRowHeight = 30.0;
    final double normalRowHeight = 42.0;

    // Calculate height based on view mode
    double totalHeight;
    if (showCompactView) {
      if (_showIntermediateStops || intermediateCount == 0) {
        // Show all stops
        totalHeight = relevantStopIndices.length * compactRowHeight;
      } else {
        // Show only origin, expander, and destination (3 rows)
        totalHeight = 3 * compactRowHeight;
      }
    } else {
      totalHeight = widget.selectedRoute.stops.length * normalRowHeight;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main stops section (title is now handled separately)
        // Add padding to allow shadows to render outside the content area
        Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: SizedBox(
            height: totalHeight,
            child: Stack(
              clipBehavior: Clip.none, // Allow shadows to extend beyond stack
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: RouteLineWithStopsPainter(
                      stopCount: showCompactView
                          ? (_showIntermediateStops || intermediateCount == 0
                              ? relevantStopIndices.length
                              : 3) // origin, expander, destination
                          : widget.selectedRoute.stops.length,
                      rowHeight: showCompactView
                          ? (_showIntermediateStops || intermediateCount == 0
                              ? compactRowHeight
                              : compactRowHeight) // Use same height for calculation
                          : normalRowHeight,
                      lineWidth: 2,
                      lineColor: Color(0xFF2E2E2E),
                      originIndex: 0,
                      destinationIndex: showCompactView
                          ? (_showIntermediateStops || intermediateCount == 0
                              ? relevantStopIndices.length - 1
                              : 2) // Last position when collapsed
                          : (widget.selectedRoute.stops.length > 1 ? widget.selectedRoute.stops.length - 1 : 0),
                      // In compact view, don't pass greyedStops - indices don't match
                      // and we're only showing the active range anyway
                      greyedStops: showCompactView ? [] : widget.greyedStops,
                    ),
                  ),
                ),
                Column(
                  children: showCompactView
                      ? _buildCompactStopsList(relevantStopIndices, intermediateCount, compactRowHeight)
                      : [
                          // Build all stops with normal height
                          ...List.generate(widget.selectedRoute.stops.length, (i) => _buildStopRow(i)),
                        ],
                ),
              ],
            ),
          ),
        ),

        // Suggestion link for new stop
        Padding(
          padding: EdgeInsets.only(top: 16, bottom: 8),
          child: InkWell(
            onTap: () => _suggestNewStop(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.add_location_outlined, size: 16, color: Colors.blue[700]),
                SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.suggestStop,
                  style: TextStyle(fontSize: 14, color: Colors.blue[700], decoration: TextDecoration.underline),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _suggestNewStop(BuildContext context) {
    final currentUser = AuthService.currentUser;
    if (currentUser == null) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.snackbarPleaseLoginToSuggestStop),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final messagingService = MessagingService();

    // Create support conversation with "New Stop Suggestion" type
    final supportConversation = messagingService.createSupportConversation(
      currentUser.id,
      currentUser.fullName,
      'New Stop Suggestion',
    );

    // Navigate to chat screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          conversation: supportConversation,
          createConversationOnFirstMessage: true,
        ),
      ),
    );
  }

  // Build the list of stops for compact view (with expandable intermediate stops)
  List<Widget> _buildCompactStopsList(List<int> relevantStopIndices, int intermediateCount, double compactRowHeight) {
    // If no intermediate stops or expanded, show all
    if (intermediateCount == 0 || _showIntermediateStops) {
      return relevantStopIndices.map((i) => _buildCompactStopRow(i)).toList();
    }

    // Collapsed view: origin, expander, destination
    return [
      _buildCompactStopRow(relevantStopIndices.first), // Origin
      _buildIntermediateExpander(intermediateCount, compactRowHeight),
      _buildCompactStopRow(relevantStopIndices.last), // Destination
    ];
  }

  // Build the expandable "X stops" row
  Widget _buildIntermediateExpander(int count, double height) {
    return InkWell(
      onTap: () {
        setState(() {
          _showIntermediateStops = true;
        });
        widget.onIntermediateExpandedChanged?.call(true);
      },
      child: Container(
        height: height,
        child: Row(
          children: [
            Container(
              width: 28,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 2,
                    height: 4,
                    color: Color(0xFF2E2E2E),
                  ),
                  SizedBox(height: 2),
                  Container(
                    width: 2,
                    height: 4,
                    color: Color(0xFF2E2E2E),
                  ),
                  SizedBox(height: 2),
                  Container(
                    width: 2,
                    height: 4,
                    color: Color(0xFF2E2E2E),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            Text(
              '$count stops',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.expand_more,
              size: 16,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  // Build a compact stop row (smaller height, same font size)
  Widget _buildCompactStopRow(int i) {
    bool isGreyed = widget.greyedStops.contains(i);
    bool isOrigin = i == widget.originIndex;
    bool isDestination = i == widget.destinationIndex;
    bool isIntermediate = !isOrigin && !isDestination;

    // Allow tapping on origin/destination to deselect
    bool disableTap = widget.isDisabled || isIntermediate;

    return InkWell(
      onTap: disableTap
          ? null
          : () {
              if (isOrigin) {
                print('🎯 StopsSection: Clearing origin (was $i)');
                widget.onOriginChanged(null);
                widget.onDestinationChanged(null);
                widget.onResetDateTime();
              } else if (isDestination) {
                print('🎯 StopsSection: Clearing destination (was $i)');
                widget.onDestinationChanged(null);
                widget.onResetDateTime();
              }
            },
      child: Container(
        height: 30.0, // Compact height
        padding: EdgeInsets.symmetric(vertical: 0),
        clipBehavior: Clip.none, // Allow shadows to extend beyond container
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 28,
              clipBehavior: Clip.none, // Allow shadows to extend beyond container
              alignment: Alignment.center,
              child: _buildStopCircleOrMarker(i, widget.originIndex, widget.destinationIndex, isGreyed),
            ),
            SizedBox(width: 8),
            // Add left padding to intermediate stops to indent them
            if (isIntermediate) SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.selectedRoute.stops[i].name,
                style: TextStyle(
                  fontSize: (isOrigin || isDestination) ? 16 : 13,
                  color: isIntermediate ? Colors.grey[600] : Colors.black,
                  fontWeight: (isOrigin || isDestination) ? FontWeight.w800 : FontWeight.normal,
                ),
                textAlign: TextAlign.left,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStopRow(int i) {
    bool isFirst = i == 0;
    bool isLast = i == widget.selectedRoute.stops.length - 1;
    bool isOrigin = i == widget.originIndex;
    bool isDestination = i == widget.destinationIndex;
    bool disableTap =
        widget.isDisabled ||
        (widget.originIndex == null && isLast) ||
        (widget.originIndex != null && widget.destinationIndex == null && isFirst && i > widget.originIndex!) ||
        // Disable taps on inactive stops when both origin and destination are selected
        (widget.originIndex != null &&
            widget.destinationIndex != null &&
            !isOrigin &&
            !isDestination);
    bool isGreyed = widget.greyedStops.contains(i);

    return InkWell(
      onTap: disableTap
          ? null
          : () {
              if (widget.originIndex == null) {
                if (!isLast) {
                  print('🎯 StopsSection: Setting origin to $i');
                  widget.onOriginChanged(i);
                  widget.onDestinationChanged(null);
                  widget.onResetDateTime();
                }
              } else if (widget.destinationIndex == null && !isOrigin && i > widget.originIndex!) {
                if (!isFirst) {
                  print('🎯 StopsSection: Setting destination to $i');
                  widget.onDestinationChanged(i);
                  // Don't reset date/time here - user may have already selected time
                }
              } else if (isOrigin) {
                print('🎯 StopsSection: Clearing origin (was $i)');
                widget.onOriginChanged(null);
                widget.onDestinationChanged(null);
                widget.onResetDateTime();
              } else if (isDestination) {
                print('🎯 StopsSection: Clearing destination (was $i)');
                widget.onDestinationChanged(null);
                widget.onResetDateTime();
              }
            },
      child: Container(
        height: 42.0,
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 28,
              alignment: Alignment.center,
              child: _buildStopCircleOrMarker(i, widget.originIndex, widget.destinationIndex, isGreyed),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.selectedRoute.stops[i].name,
                style: TextStyle(
                  fontSize: (i == widget.originIndex || i == widget.destinationIndex) ? 16 : 14,
                  // Check origin/destination FIRST, before isGreyed
                  color: (i == widget.originIndex || i == widget.destinationIndex)
                      ? Colors.black
                      : (isGreyed ? Colors.grey : Color(0xFF2E2E2E)),
                  fontWeight: (i == widget.originIndex || i == widget.destinationIndex) ? FontWeight.w800 : FontWeight.normal,
                ),
                textAlign: TextAlign.left,
                maxLines: 2,
                overflow: TextOverflow.visible,
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStopCircleOrMarker(int i, int? originIndex, int? destinationIndex, bool isGreyed) {
    if (i == originIndex) {
      // Larger origin marker - green with grey outer ring, white middle, green center
      return Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: Colors.grey[400],
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      );
    } else if (i == destinationIndex) {
      // Larger destination marker - red with grey outer ring, white middle, red center
      return Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: Colors.grey[400],
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      // Regular stop marker - simple border, no shadow
      return Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: isGreyed ? Color(0xFF2E2E2E).withValues(alpha: 0.5) : Color(0xFF2E2E2E), width: 2),
          shape: BoxShape.circle,
        ),
      );
    }
  }

}
