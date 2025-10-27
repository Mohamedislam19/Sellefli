import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class Avatar extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final double size;
  final bool showOnline;

  const Avatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.size = 52,
    this.showOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = imageUrl == null || imageUrl!.isEmpty
        ? CircleAvatar(
            radius: size / 2,
            backgroundColor: Colors.grey.shade200,
            child: Text(
              initials ?? '?',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: size / 2.6,
                color: Colors.black87,
              ),
            ),
          )
        : CircleAvatar(
            radius: size / 2,
            backgroundImage: NetworkImage(imageUrl!),
            backgroundColor: Colors.grey.shade200,
          );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        if (showOnline)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: size / 5.2,
              height: size / 5.2,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
