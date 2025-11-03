// lib/src/features/map/map_picker_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sellefli/src/core/theme/app_theme.dart';
import 'package:sellefli/src/core/widgets/map/coordinates_display.dart';

import 'package:sellefli/src/core/widgets/animated_return_button.dart';
import 'package:sellefli/src/core/widgets/snack/top_snack.dart';

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({Key? key}) : super(key: key);

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  late MapController _mapController;
  LatLng selectedLatLng = LatLng(36.7538, 3.0588);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  Future<void> _centerOnCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      TopSnack.show(context, 'Location services are disabled.', false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        TopSnack.show(context, 'Location permission denied.', false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      TopSnack.show(context, 'Location permission permanently denied.', false);
      return;
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      LatLng currentLocation = LatLng(pos.latitude, pos.longitude);

      _mapController.move(currentLocation, 16);
      setState(() {
        selectedLatLng = currentLocation;
      });
      TopSnack.show(context, 'Location set to your current position!', true);
    } catch (e) {
      TopSnack.show(context, 'Failed to get location. Try again.', false);
    }
  }

  void _onMapMove(MapPosition pos, bool hasGesture) {
    if (pos.center != null) {
      setState(() {
        selectedLatLng = pos.center!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Scale factor between 0.7 (at 245px) and 1 (at 350px or higher)
    final scale = (screenWidth / 350).clamp(0.7, 1.0);
    final double screenW = screenWidth;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 207, 225, 255),
        elevation: 1,
        centerTitle: true,
        leading: const AnimatedReturnButton(),
        title: Padding(
          padding: EdgeInsets.symmetric(vertical: 12 * scale),
          child: Text(
            'Map',
            style: GoogleFonts.outfit(
              fontSize: 22 * scale,
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: selectedLatLng,
              zoom: 16.0,
              maxZoom: 18,
              minZoom: 2,
              interactiveFlags: InteractiveFlag.all,
              onPositionChanged: _onMapMove,
              onTap: (tapPosition, point) {
                setState(() {
                  selectedLatLng = point;
                  _mapController.move(point, _mapController.zoom);
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                backgroundColor: Colors.white,
                userAgentPackageName: 'com.sellefli.map',
              ),
            ],
          ),
          Center(
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.only(bottom: 32),
                child: Icon(
                  Icons.location_on_rounded,
                  size: screenW * 0.15 + 10,
                  color: AppColors.primaryBlue,
                  shadows: [
                    Shadow(
                      color: AppColors.primaryBlue.withOpacity(0.2),
                      blurRadius: 38,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 210,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.97),
                    Colors.white.withOpacity(0.7),
                    Colors.white.withOpacity(0.1),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 70,
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.my_location, color: AppColors.primaryBlue),
                    label: Text(
                      'Localize to Current Location',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      backgroundColor: Colors.white,
                      shadowColor: AppColors.primaryBlue.withOpacity(0.12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: AppColors.primaryBlue, width: 1.4),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 4,
                      ),
                    ),
                    onPressed: _centerOnCurrentLocation,
                  ),
                ),
                const SizedBox(height: 13),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      // TopSnack.show(context, 'Location confirmed!', true);
                      Navigator.pop(context, {
                        'latlng': selectedLatLng,
                        'address': '', // add reverse geocoding here if desired
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shadowColor: AppColors.primaryBlue.withOpacity(0.22),
                      elevation: 2,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.05,
                        fontSize: 17,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Confirm Location"),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 15,
            child: CoordinatesDisplay(position: selectedLatLng),
          ),
        ],
      ),
    );
  }
}
