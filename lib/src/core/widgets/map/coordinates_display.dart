// lib/src/core/widgets/map/coordinates_display.dart
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../theme/app_theme.dart';
import 'package:sellefli/src/core/theme/app_theme.dart';

class CoordinatesDisplay extends StatelessWidget {
  final LatLng position;
  final double fontSize;
  final double borderRadius;
  final EdgeInsets padding;

  const CoordinatesDisplay({
    Key? key,
    required this.position,
    this.fontSize = 15.6,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.97),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.11),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: padding,
        child: Text(
          'Lat: ${position.latitude.toStringAsFixed(6)}  |  '
          'Lng: ${position.longitude.toStringAsFixed(6)}',
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
            letterSpacing: 0.15,
          ),
        ),
      ),
    );
  }
}
