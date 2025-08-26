import 'package:flutter/material.dart';
import '../models/routes.dart';
import '../screens/route_line_with_stops.dart';

class StopsSectionWidget extends StatefulWidget {
  final bool hideUnusedStops;
  final RouteInfo selectedRoute;
  final int? originIndex;
  final int? destinationIndex;
  final List<int> greyedStops;
  final Function(int?) onOriginChanged;
  final Function(int?) onDestinationChanged;
  final VoidCallback onResetDateTime;

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
  });

  @override
  State<StopsSectionWidget> createState() => _StopsSectionWidgetState();
}

class _StopsSectionWidgetState extends State<StopsSectionWidget> {
  @override
  Widget build(BuildContext context) {
    // Filter stops if hideUnusedStops is true and both origin and destination are selected
    List<StopInfo> visibleStops = widget.selectedRoute.stops;
    if (widget.hideUnusedStops &&
        widget.originIndex != null &&
        widget.destinationIndex != null) {
      int start = widget.originIndex!;
      int end = widget.destinationIndex!;
      if (start > end) {
        int temp = start;
        start = end;
        end = temp;
      }
      visibleStops = visibleStops.sublist(start, end + 1);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main stops section (title is now handled separately)
        SizedBox(
          height: visibleStops.length * 42.0,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: RouteLineWithStopsPainter(
                    stopCount: visibleStops.length,
                    rowHeight: 42,
                    lineWidth: 2,
                    lineColor: Color(0xFF2E2E2E),
                    originIndex: 0,
                    destinationIndex: visibleStops.length > 1
                        ? visibleStops.length - 1
                        : 0,
                    greyedStops: const [],
                  ),
                ),
              ),
              Column(
                children: [
                  // Only build visible stops
                  ...List.generate(
                    visibleStops.length,
                    (i) => _buildVisibleStopRow(visibleStops, i),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper to build stop row for visible stops
  Widget _buildVisibleStopRow(List<StopInfo> stops, int i) {
    // You may want to adjust the tap/grey logic for visible stops if needed
    return _buildStopRow(widget.selectedRoute.stops.indexOf(stops[i]));
  }

  Widget _buildStopRow(int i) {
    bool isFirst = i == 0;
    bool isLast = i == widget.selectedRoute.stops.length - 1;
    bool disableTap =
        (widget.originIndex == null && isLast) ||
        (widget.originIndex != null &&
            widget.destinationIndex == null &&
            isFirst &&
            i > widget.originIndex!) ||
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
                  widget.onOriginChanged(i);
                  widget.onDestinationChanged(null);
                }
              } else if (widget.destinationIndex == null &&
                  i != widget.originIndex &&
                  i > widget.originIndex!) {
                if (!isFirst) {
                  widget.onDestinationChanged(i);
                }
              } else if (i == widget.originIndex) {
                widget.onOriginChanged(null);
                widget.onDestinationChanged(null);
              } else if (i == widget.destinationIndex) {
                widget.onDestinationChanged(null);
              }
              widget.onResetDateTime();
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
              child: _buildStopCircleOrMarker(
                i,
                widget.originIndex,
                widget.destinationIndex,
                isGreyed,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.selectedRoute.stops[i].name,
                style: TextStyle(
                  fontSize: 13,
                  color: isGreyed
                      ? Colors.grey
                      : (i == widget.destinationIndex
                            ? Color(0xFFDD2C00)
                            : (i == widget.originIndex
                                  ? Color(0xFF00C853)
                                  : Color(0xFF2E2E2E))),
                  fontWeight:
                      (i == widget.originIndex || i == widget.destinationIndex)
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

  Widget _buildStopCircleOrMarker(
    int i,
    int? originIndex,
    int? destinationIndex,
    bool isGreyed,
  ) {
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
          // Inner circle - dark grey for origin
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Color(0xFF2E2E2E),
              shape: BoxShape.circle,
            ),
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
          // Inner circle - dark grey for destination
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Color(0xFF2E2E2E),
              shape: BoxShape.circle,
            ),
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
          border: Border.all(
            color: isGreyed
                ? Color(0xFF2E2E2E).withValues(alpha: 0.5)
                : Color(0xFF2E2E2E),
            width: 2,
          ),
          shape: BoxShape.circle,
        ),
      );
    }
  }
}
