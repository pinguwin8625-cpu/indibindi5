import 'package:flutter/material.dart';
import '../models/routes.dart';
import '../screens/route_line_with_stops.dart';
import '../l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

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
  });

  @override
  State<StopsSectionWidget> createState() => _StopsSectionWidgetState();
}

class _StopsSectionWidgetState extends State<StopsSectionWidget> {
  @override
  Widget build(BuildContext context) {
    // When both origin and destination are selected, show compact view with all stops
    final bool showCompactView =
        widget.hideUnusedStops && widget.originIndex != null && widget.destinationIndex != null;

    // Get stops between origin and destination (inclusive)
    List<int> relevantStopIndices = [];
    if (showCompactView) {
      for (int i = widget.originIndex!; i <= widget.destinationIndex!; i++) {
        relevantStopIndices.add(i);
      }
    }

    // Use smaller row height in compact view (24px vs 42px)
    final double compactRowHeight = 24.0;
    final double normalRowHeight = 42.0;

    // Calculate height based on view mode
    final double totalHeight = showCompactView
        ? relevantStopIndices.length * compactRowHeight
        : widget.selectedRoute.stops.length * normalRowHeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main stops section (title is now handled separately)
        SizedBox(
          height: totalHeight,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: RouteLineWithStopsPainter(
                    stopCount: showCompactView ? relevantStopIndices.length : widget.selectedRoute.stops.length,
                    rowHeight: showCompactView ? compactRowHeight : normalRowHeight,
                    lineWidth: 2,
                    lineColor: Color(0xFF2E2E2E),
                    originIndex: 0,
                    destinationIndex: showCompactView
                        ? relevantStopIndices.length - 1
                        : (widget.selectedRoute.stops.length > 1 ? widget.selectedRoute.stops.length - 1 : 0),
                    greyedStops: widget.greyedStops,
                  ),
                ),
              ),
              Column(
                children: showCompactView
                    ? [
                        // Build all stops between origin and destination with compact height
                        ...relevantStopIndices.map((i) => _buildCompactStopRow(i)),
                      ]
                    : [
                        // Build all stops with normal height
                        ...List.generate(widget.selectedRoute.stops.length, (i) => _buildStopRow(i)),
                      ],
              ),
            ],
          ),
        ),

        // Suggestion link for new stop
        Padding(
          padding: EdgeInsets.only(top: 16, bottom: 8),
          child: InkWell(
            onTap: () => _launchURL('https://forms.gle/yourstopformlink'),
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

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  // Build a compact stop row (smaller height, same font size)
  Widget _buildCompactStopRow(int i) {
    bool isGreyed = widget.greyedStops.contains(i);
    bool isOrigin = i == widget.originIndex;
    bool isDestination = i == widget.destinationIndex;

    // Allow tapping on origin/destination to deselect
    bool disableTap = widget.isDisabled || (!isOrigin && !isDestination);

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
        height: 24.0, // Compact height
        padding: EdgeInsets.symmetric(vertical: 2),
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
                  fontSize: 14, // Same font size as normal view
                  color: isGreyed ? Colors.grey : Color(0xFF2E2E2E),
                  fontWeight: (isOrigin || isDestination) ? FontWeight.bold : FontWeight.normal,
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
    bool disableTap =
        widget.isDisabled ||
        (widget.originIndex == null && isLast) ||
        (widget.originIndex != null && widget.destinationIndex == null && isFirst && i > widget.originIndex!) ||
        // Disable taps on inactive stops when both origin and destination are selected
        (widget.originIndex != null &&
            widget.destinationIndex != null &&
            i != widget.originIndex &&
            i != widget.destinationIndex);
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
              } else if (widget.destinationIndex == null && i != widget.originIndex && i > widget.originIndex!) {
                if (!isFirst) {
                  print('🎯 StopsSection: Setting destination to $i');
                  widget.onDestinationChanged(i);
                  // Don't reset date/time here - user may have already selected time
                }
              } else if (i == widget.originIndex) {
                print('🎯 StopsSection: Clearing origin (was $i)');
                widget.onOriginChanged(null);
                widget.onDestinationChanged(null);
                widget.onResetDateTime();
              } else if (i == widget.destinationIndex) {
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
                  fontSize: 14,
                  color: isGreyed ? Colors.grey : Color(0xFF2E2E2E), // Use same dark color for all stops
                  fontWeight: (i == widget.originIndex || i == widget.destinationIndex)
                      ? FontWeight.bold
                      : FontWeight.normal,
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
      // Google Maps style origin marker
      return Stack(
        alignment: Alignment.center,
        children: [
          // Outer circle
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 2,
                  spreadRadius: 1,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
          // Inner circle - green for origin
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
          ),
        ],
      );
    } else if (i == destinationIndex) {
      // Google Maps style destination marker
      return Stack(
        alignment: Alignment.center,
        children: [
          // Outer circle
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 2,
                  spreadRadius: 1,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
          // Inner circle - red for destination
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
          ),
        ],
      );
    } else {
      // Regular stop marker
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
