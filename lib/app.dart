import 'package:flutter/material.dart';
import 'package:sellefli/src/core/widgets/rating_widget.dart';
import 'package:sellefli/src/features/Booking/booking_detail_page.dart';
import 'package:sellefli/src/features/auth/auth_screen.dart';
import 'package:sellefli/src/features/home/marketplace_home_page.dart';
import 'package:sellefli/src/features/item/edit_item.dart';
import 'package:sellefli/src/features/item/item_details.dart';
import 'package:sellefli/src/features/landing/landing_page.dart';
import 'package:sellefli/src/features/listing/my_listings.dart';
import 'package:sellefli/src/features/map/map_picker.dart';
import 'package:sellefli/src/features/orders/requests_orders_page.dart';
import 'package:sellefli/src/features/profile/profile.dart';
import 'package:sellefli/src/features/settings/settings_page.dart';
import 'package:sellefli/src/features/profile/edit_profile_page.dart';
import 'package:sellefli/src/features/item/create_item_page.dart'; // <-- Add this import
import 'src/core/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sellefli',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => LandingPage(),
        '/map-picker': (context) => const MapPickerPage(),
        '/settings': (context) => SettingsHelpPage(),
        '/create-item': (context) => const CreateItemPage(),
        '/edit-item': (context) => const EditItemPage(),
        '/auth': (context) => const AuthScreen(),
        '/request-order': (context) => const RequestsOrdersPage(),
        '/booking-details': (context) => const BookingDetailPage(),
        '/item-details': (context) => const ItemDetailsPage(),
        '/profile-page': (context) => const ProfilePage(),
        '/edit-profile': (context) => const EditProfilePage(),
        '/listings': (context) => const MyListingsPage(),
        '/home': (context) => const MarketplaceHomePage(),
        '/rating': (context) => RatingWidget(),
      },
    );
  }
}
