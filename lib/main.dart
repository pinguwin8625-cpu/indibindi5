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
      theme: ThemeData(primarySwatch: Colors.red),
      home: const HomeScreen(),
    );
  }
}
