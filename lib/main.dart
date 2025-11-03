// lib/main.dart
import 'package:flutter/material.dart';
import 'src/features/orders/requests_orders_page.dart';
import 'src/features/landing/landing_page.dart';
import 'src/features/Booking/booking_detail_page.dart';
import 'src/features/components_showcase/components_showcase_page.dart';



// import 'src/features/bookings/booking_detail_page.dart';

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
      home: const BookingDetailPage(),
      // To test Booking Details page, use:
      // home: const BookingDetailPage(),
    );
  }
}