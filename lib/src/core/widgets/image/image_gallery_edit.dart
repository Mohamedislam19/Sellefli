import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ImageGallery extends StatelessWidget {
  // Mixed list: XFile (new), String (remote URL), or null (empty)
  final List<Object?> images;
  final double scale;
  final bool showImageError;
  final void Function(int index) onRemove;

  const ImageGallery({
    super.key,
    required this.images,
    required this.scale,
    required this.showImageError,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    // Build (index, value) pairs but only for non-null items so removal maps to original index
    final List<MapEntry<int, Object>> visible = images
        .asMap()
        .entries
        .where((e) => e.value != null)
        .map((e) => MapEntry(e.key, e.value as Object))
        .toList();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOut,
      margin: EdgeInsets.only(bottom: 8 * scale, top: 2 * scale),
      padding: EdgeInsets.all(10 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: showImageError ? Colors.red : Colors.grey[300]!,
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(13 * scale),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: visible.isEmpty
            ? Column(
                key: const ValueKey('picker-empty'),
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    color: Colors.grey[300],
                    size: 44 * scale,
                  ),
                  SizedBox(height: 7 * scale),
                  Text(
                    'No image selected',
                    style: GoogleFonts.outfit(
                      color: Colors.grey[400],
                      fontSize: 13 * scale,
                    ),
                  ),
                ],
              )
            : SizedBox(
                key: const ValueKey('picker-full'),
                height: 85 * scale,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: visible.length,
                  separatorBuilder: (_, __) => SizedBox(width: 9 * scale),
                  itemBuilder: (_, idx) {
                    final originalIndex = visible[idx].key;
                    final item = visible[idx].value;
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.5 * scale),
                          child: _buildImage(item, scale),
                        ),
                        Positioned(
                          top: 3,
                          right: 3,
                          child: GestureDetector(
                            onTap: () => onRemove(originalIndex),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black87,
                                shape: BoxShape.circle,
                              ),
                              padding: EdgeInsets.all(2.7 * scale),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 17,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildImage(Object item, double scale) {
    if (item is XFile) {
      return Image.file(
        File(item.path),
        width: 85 * scale,
        height: 85 * scale,
        fit: BoxFit.cover,
      );
    } else if (item is String) {
      return Image.network(
        item,
        width: 85 * scale,
        height: 85 * scale,
        fit: BoxFit.cover,
        errorBuilder: (ctx, _, __) => Container(
          width: 85 * scale,
          height: 85 * scale,
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image),
        ),
      );
    }
    return SizedBox(
      width: 85 * scale,
      height: 85 * scale,
      child: const ColoredBox(color: Colors.transparent),
    );
  }
}


