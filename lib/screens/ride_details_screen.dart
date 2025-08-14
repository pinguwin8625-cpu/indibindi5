import 'package:flutter/material.dart';

class RideDetailsScreen extends StatelessWidget {
  const RideDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ride Details')),
      body: Center(child: Text('Ride info and booking')),
    );
  }
}
