import 'package:flutter/material.dart';
import 'src/core/theme/app_theme.dart';
import 'src/features/components_showcase/components_showcase_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sellefli',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      initialRoute: '/',
      routes: {'/': (context) => const ComponentsShowcasePage()},
    );
  }
}
