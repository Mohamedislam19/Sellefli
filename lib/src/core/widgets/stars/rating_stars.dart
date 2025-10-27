import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class RatingStars extends StatelessWidget {
  final double rating; // e.g. 4.5
  final double size;
  const RatingStars({super.key, required this.rating, this.size = 18});

  @override
  Widget build(BuildContext context) {
    final List<Widget> stars = [];
    for (int i = 1; i <= 5; i++) {
      if (rating >= i) {
        stars.add(Icon(Icons.star, size: size, color: AppColors.star));
      } else if (rating >= i - 0.5) {
        stars.add(Icon(Icons.star_half, size: size, color: AppColors.star));
      } else {
        stars.add(
          Icon(
            Icons.star_border,
            size: size,
            color: AppColors.star.withOpacity(0.4),
          ),
        );
      }
    }
    return Row(children: stars);
  }
}
