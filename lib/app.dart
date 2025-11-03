import 'package:flutter/material.dart';
import 'package:sellefli/src/features/Booking/booking_detail_page.dart';
<<<<<<< Updated upstream
import 'package:sellefli/src/features/auth/auth_screen.dart';
=======
>>>>>>> Stashed changes
import 'package:sellefli/src/features/components_showcase/components_showcase_page.dart';
import 'package:sellefli/src/features/landing/landing_page.dart';
import 'package:sellefli/src/features/map/map_picker.dart';
import 'package:sellefli/src/features/settings/settings_page.dart';
import 'package:sellefli/src/features/item/create_item_page.dart'; // <-- Add this import
import 'src/core/theme/app_theme.dart';
import 'screens/auth_screen.dart';
import 'screens/login_form.dart';
import 'screens/reset_password_form.dart';
import 'screens/signup_form.dart';



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sellefli',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      initialRoute: '/',
      routes: {'/': (context) => AuthScreen(),
       '/map-picker': (context) => const MapPickerPage(),
      },
    );
  }
}
