// lib/src/core/widgets/image/image_gallery.dart
// ignore_for_file: use_super_parameters

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

typedef RemoveImageCallback = void Function(int index);

class ImageGallery extends StatelessWidget {
  final List<XFile> images;
  final double scale;
  final bool showImageError;
  final RemoveImageCallback onRemove;

  const ImageGallery({
    Key? key,
    required this.images,
    required this.scale,
    required this.showImageError,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        child: images.isEmpty
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
                  itemCount: images.length,
                  separatorBuilder: (_, __) => SizedBox(width: 9 * scale),
                  itemBuilder: (_, idx) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.5 * scale),
                        child: Image.file(
                          File(images[idx].path),
                          width: 85 * scale,
                          height: 85 * scale,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: () => onRemove(idx),
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
                  ),
                ),
              ),
      ),
    );
  }
}


