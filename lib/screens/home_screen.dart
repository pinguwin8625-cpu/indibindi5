import 'package:flutter/material.dart';
import '../models/routes.dart';
import 'vertical_route_line_painter.dart';

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
          children: [_buildTabContent('driver'), _buildTabContent('rider')],
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
                height: selectedRoute.stops.length * 40.0,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: VerticalRouteLinePainter(
                          stopCount: selectedRoute.stops.length,
                          rowHeight: 40,
                          lineWidth: 2,
                        ),
                      ),
                    ),
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: selectedRoute.stops.length,
                      itemBuilder: (context, i) {
                        Widget? marker;
                        if (i == originIndex) {
                          marker = Icon(
                            Icons.circle,
                            color: Colors.blue[900],
                            size: 18,
                          );
                        } else if (i == destinationIndex) {
                          marker = Icon(Icons.flag, color: Colors.red, size: 18);
                        }
                        return InkWell(
                          onTap: () {
                            setState(() {
                              if (originIndex == null) {
                                originIndex = i;
                                destinationIndex = null;
                              } else if (destinationIndex == null &&
                                  i != originIndex &&
                                  i > originIndex!) {
                                destinationIndex = i;
                              } else if (i == originIndex) {
                                originIndex = null;
                                destinationIndex = null;
                              } else if (i == destinationIndex) {
                                destinationIndex = null;
                              }
                            });
                          },
                          child: SizedBox(
                            height: 40.0,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 28,
                                  child: Center(child: marker),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      selectedRoute.stops[i],
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: i == destinationIndex
                                            ? Colors.red
                                            : (i == originIndex
                                                  ? Colors.blue
                                                  : Colors.black),
                                        fontWeight:
                                            (i == originIndex || i == destinationIndex)
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                      ),
                                    ),
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
}
