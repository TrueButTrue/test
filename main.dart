import 'package:flutter/material.dart';
import 'activity_assignment_screen.dart';
import 'admin_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volunteer App',
      home: ActivityAssignmentScreen(),
      routes: {
        '/admin': (context) => const AdminScreen(),
      },
    );
  }
}
