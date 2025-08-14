import 'vertical_route_line_painter.dart';
import 'package:flutter/material.dart';
import '../models/routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('indibindi', style: TextStyle(letterSpacing: 1)),
          backgroundColor: Colors.red,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'driver'),
              Tab(text: 'rider'),
            ],
            labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        body: TabBarView(
          children: [
            _buildTabContent('driver'),
            _buildTabContent('rider'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(String role) {
    RouteInfo selectedRoute = predefinedRoutes[0];
    int? originIndex;
    int? destinationIndex;

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
              child: DropdownButton<RouteInfo>(
                value: selectedRoute,
                isExpanded: true,
                items: predefinedRoutes.map((route) {
                  return DropdownMenuItem<RouteInfo>(
                    value: route,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            route.name,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '${route.distance} • ${route.duration}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedRoute = value;
                      originIndex = null;
                      destinationIndex = null;
                    });
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: SizedBox(
                height: selectedRoute.stops.length * 28.0,
                child: Stack(
                  children: [
                    // Draw the vertical dashed line behind the stops
                    Positioned.fill(
                      child: CustomPaint(
                        painter: VerticalRouteLinePainter(
                          stopCount: selectedRoute.stops.length,
                          rowHeight: 28,
                          lineWidth: 2,
                        ),
                      ),
                    ),
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: selectedRoute.stops.length,
                      itemBuilder: (context, i) {
                        bool isFirst = i == 0;
                        bool isLast = i == selectedRoute.stops.length - 1;
                        bool disableTap =
                            (originIndex == null && isLast) ||
                            (originIndex != null &&
                                destinationIndex == null &&
                                isFirst &&
                                i > originIndex!);
                        return InkWell(
                          onTap: disableTap
                              ? null
                              : () {
                                  setState(() {
                                    if (originIndex == null) {
                                      if (!isLast) {
                                        originIndex = i;
                                        destinationIndex = null;
                                      }
                                    } else if (destinationIndex == null &&
                                        i != originIndex &&
                                        i > originIndex!) {
                                      if (!isFirst) {
                                        destinationIndex = i;
                                      }
                                    } else if (i == originIndex) {
                                      originIndex = null;
                                      destinationIndex = null;
                                    } else if (i == destinationIndex) {
                                      destinationIndex = null;
                                    }
                                  });
                                },
                          child: SizedBox(
                            height: 28.0,
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  alignment: Alignment.center,
                                  child: _buildStopCircleOrMarker(i, originIndex, destinationIndex),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    selectedRoute.stops[i],
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: i == destinationIndex
                                          ? Colors.red
                                          : (i == originIndex
                                                ? Colors.blue
                                                : Colors.black),
                                      fontWeight:
                                          (i == originIndex ||
                                              i == destinationIndex)
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStopCircleOrMarker(int i, int? originIndex, int? destinationIndex) {
    // All icons/circles are centered at x=14, matching the route line
    if (i == originIndex) {
      return Container(
        width: 18,
        height: 18,
        alignment: Alignment.center,
        child: Icon(Icons.radio_button_checked, color: Colors.green, size: 18),
      );
    } else if (i == destinationIndex) {
      return Container(
        width: 20,
        height: 20,
        alignment: Alignment.center,
        child: Icon(Icons.location_on, color: Colors.red, size: 20),
      );
    } else {
      return Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey, width: 2),
          shape: BoxShape.circle,
        ),
      );
    }
  }
}