// lib/main.dart
import 'package:flutter/material.dart';
import 'package:sellefli/marketplace_home_page.dart';
import 'package:sellefli/src/features/auth/auth_screen.dart';
import 'src/features/Booking/booking_detail_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sellefli App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const AuthScreen(),
      // To test Booking Details page, use:
      // home: const BookingDetailPage(),
    );
  }
}
