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
          children: [_buildTabContent('driver'), _buildTabContent('rider')],
        ),
      ),
                );
              }

  // Removed duplicate and incomplete _buildTabContent definition that caused the error.

  Widget _buildTabContent(String role) {
    RouteInfo selectedRoute = predefinedRoutes[0];

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
                    });
                  }
                },
              ),
            ),
            // ...add more widgets below for flow-oriented UI...
          ],
        );
      },
    );
  }
}
