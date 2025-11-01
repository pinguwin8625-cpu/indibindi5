import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const IndibindiApp());
}

class IndibindiApp extends StatelessWidget {
  const IndibindiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'indibindi',
      theme: ThemeData(
        primarySwatch: Colors.red,
        primaryColor: Color(0xFFDD2C00), // Use custom red as primary color
      ),
      home: const HomeScreen(),
    );
  }
}
