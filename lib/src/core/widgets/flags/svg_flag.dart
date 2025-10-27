// lib/src/core/widgets/flags/svg_flag.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgFlag extends StatelessWidget {
  final String? countryCode; // 'us', 'dz', 'fr', etc.
  final double size;
  final String? labelFallback; // optional fallback text (e.g., 'DZ')

  const SvgFlag({
    Key? key,
    this.countryCode,
    this.size = 24,
    this.labelFallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (countryCode == null || countryCode!.isEmpty) {
      return _fallback();
    }

    final assetPath = 'assets/flags/${countryCode!.toLowerCase()}.svg';
    // We attempt to render the SVG. If missing or error, show fallback circle with initials.
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: size,
        height: size,
        child: SvgPicture.asset(
          assetPath,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholderBuilder: (context) => Center(
            child: SizedBox(
              width: size * 0.5,
              height: size * 0.5,
              child: CircularProgressIndicator(strokeWidth: 1.6),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fallback() {
    final text = (labelFallback ?? (countryCode ?? '')).toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text.isEmpty ? '?' : text,
        style: TextStyle(fontSize: size / 2.4, fontWeight: FontWeight.w700),
      ),
    );
  }
}
