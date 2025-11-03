// lib/main.dart
import 'package:flutter/material.dart';
import 'package:sellefli/src/features/item/create_item_page.dart';
import 'package:sellefli/src/features/item/edit_item.dart';
import 'package:sellefli/src/features/item/item_details.dart';
import 'package:sellefli/src/features/listing/my_listings.dart';
import 'package:sellefli/src/features/profile/profile.dart';
import 'src/features/orders/requests_orders_page.dart';
import 'src/features/landing/landing_page.dart';
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
      home: const MyListingsPage(),
      // To test Booking Details page, use:
      // home: const BookingDetailPage(),
    );
  }
}
