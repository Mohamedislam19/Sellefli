import 'package:flutter/material.dart';
import 'package:sellefli/screens/auth_screen.dart';
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
      home: AuthScreen(),
    );
  }
}
