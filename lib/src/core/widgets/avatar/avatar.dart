import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
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

  /// Clear the cache for a specific avatar URL
  static Future<void> clearCacheForUrl(String url) async {
    await DefaultCacheManager().removeFile(url);
  }

  /// Clear all avatar cache
  static Future<void> clearAllCache() async {
    await DefaultCacheManager().emptyCache();
  }

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
            backgroundImage: CachedNetworkImageProvider(
              imageUrl!,
              cacheKey:
                  imageUrl, // Use URL as cache key to auto-refresh on URL change
            ),
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
