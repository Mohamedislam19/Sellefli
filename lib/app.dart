import 'package:flutter/material.dart';
import 'package:sellefli/src/features/Booking/booking_detail_page.dart';
import 'package:sellefli/src/features/components_showcase/components_showcase_page.dart';
import 'package:sellefli/src/features/landing/landing_page.dart';
import 'package:sellefli/src/features/map/map_picker.dart';
import 'package:sellefli/src/features/settings/settings_page.dart';
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
      routes: {'/': (context) => SettingsHelpPage(),
       '/map-picker': (context) => const MapPickerPage(),
      },
    );
  }
}
