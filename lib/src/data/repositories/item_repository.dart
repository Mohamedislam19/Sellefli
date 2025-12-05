// ignore_for_file: unnecessary_null_comparison

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/item_model.dart';
import '../models/item_image_model.dart';
import '../local/local_item_repository.dart';

class ItemRepository {
  final SupabaseClient supabase;
  final LocalItemRepository _localRepo = LocalItemRepository();

  ItemRepository(this.supabase);

  // ===========================================================================
  // CREATE ITEM
  // ===========================================================================
  Future<String> createItem(Item item) async {
    final response = await supabase
        .from('items')
        .insert(item.toJson())
        .select()
        .single();

    return response['id'] as String;
  }

  // ===========================================================================
  // UPLOAD IMAGES  (items/<itemId>/<filename>)
  // Returns list of inserted ItemImage records
  // ===========================================================================
  Future<List<ItemImage>> uploadItemImages(
    String itemId,
    List<File> images,
  ) async {
    final List<ItemImage> inserted = [];

    for (int i = 0; i < images.length; i++) {
      final file = images[i];
      final ext = file.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      final storagePath = 'items/$itemId/$fileName';

      // Upload to storage
      final uploadResponse = await supabase.storage
          .from('item-images')
          .upload(storagePath, file);

      // Supabase storage upload returns a Map on success; treat empty as failure
      if (uploadResponse == null ||
          // ignore: unnecessary_type_check
          (uploadResponse is String && uploadResponse.isEmpty)) {
        // some SDK versions return a map, some return void - we'll still proceed to check by trying to get a public URL
        // but if you want stricter checking, wrap upload in try/catch and throw on exception
      }

      // Public URL
      final publicUrl = supabase.storage
          .from('item-images')
          .getPublicUrl(storagePath);

      // Insert DB record and return inserted row
      final insertedRow = await supabase
          .from('item_images')
          .insert({
            'item_id': itemId,
            'image_url': publicUrl,
            'position': i + 1,
          })
          .select()
          .single();

      inserted.add(ItemImage.fromJson(insertedRow));
    }

    return inserted;
  }

  // Upload a single image at a specific position
  Future<ItemImage> uploadItemImageAtPosition(
    String itemId,
    File file,
    int position,
  ) async {
    final ext = file.path.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
    final storagePath = 'items/$itemId/$fileName';
    final contentType = _guessContentType(ext);
    await supabase.storage
        .from('item-images')
        .upload(
          storagePath,
          file,
          fileOptions: FileOptions(contentType: contentType),
        );

    final publicUrl = supabase.storage
        .from('item-images')
        .getPublicUrl(storagePath);

    final insertedRow = await supabase
        .from('item_images')
        .insert({
          'item_id': itemId,
          'image_url': publicUrl,
          'position': position,
        })
        .select()
        .single();

    return ItemImage.fromJson(insertedRow);
  }

  // Web-safe upload directly from XFile, falling back to File for non-web.
  Future<ItemImage> uploadXFileAtPosition(
    String itemId,
    XFile xfile,
    int position,
  ) async {
    final ext = (xfile.name.split('.').length > 1)
        ? xfile.name.split('.').last
        : 'jpg';
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
    final storagePath = 'items/$itemId/$fileName';

    if (kIsWeb) {
      final bytes = await xfile.readAsBytes();
      final contentType = _guessContentType(ext);
      await supabase.storage
          .from('item-images')
          .uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(contentType: contentType),
          );
    } else {
      final contentType = _guessContentType(ext);
      await supabase.storage
          .from('item-images')
          .upload(
            storagePath,
            File(xfile.path),
            fileOptions: FileOptions(contentType: contentType),
          );
    }

    final publicUrl = supabase.storage
        .from('item-images')
        .getPublicUrl(storagePath);
    final insertedRow = await supabase
        .from('item_images')
        .insert({
          'item_id': itemId,
          'image_url': publicUrl,
          'position': position,
        })
        .select()
        .single();
    return ItemImage.fromJson(insertedRow);
  }

  String _guessContentType(String ext) {
    final lower = ext.toLowerCase();
    switch (lower) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return 'application/octet-stream';
    }
  }

  // ===========================================================================
  // GET ITEMS (Feed)
  // ===========================================================================
  Future<List<Item>> getItems({
    required int page,
    required int pageSize,
    String? excludeUserId,
    List<String>? categories,
    String? searchQuery,
  }) async {
    try {
      dynamic query = supabase
          .from('items')
          .select(
            '*, item_images(image_url, position), users!inner(username, avatar_url, rating_sum, rating_count)',
          );

      // Exclude current user's items
      if (excludeUserId != null) {
        query = query.neq('owner_id', excludeUserId);
      }

      // Category Filter
      if (categories != null &&
          categories.isNotEmpty &&
          !categories.contains('All')) {
        query = query.inFilter('category', categories);
      }

      // Search Filter (Partial match)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('title', '%$searchQuery%');
      }

      // Order by creation date (newest first)
      query = query.order('created_at', ascending: false);

      // Pagination
      final from = (page - 1) * pageSize;
      final to = from + pageSize - 1;
      query = query.range(from, to);

      final data = await query;
      final items = (data as List).map((json) => Item.fromJson(json)).toList();

      // Cache first page if no filters are applied
      if (page == 1 &&
          (searchQuery == null || searchQuery.isEmpty) &&
          (categories == null ||
              categories.isEmpty ||
              categories.contains('All'))) {
        // Fire and forget caching
        _localRepo.cacheItems(items.take(10).toList());
      }

      return items;
    } catch (e) {
      // If network fails and it's the first page, try local cache
      if (page == 1) {
        final cachedItems = await _localRepo.getCachedItems();
        if (cachedItems.isNotEmpty) {
          return cachedItems;
        }
      }
      rethrow;
    }
  }

  // ===========================================================================
  // GET ITEM
  // ===========================================================================
  Future<Item?> getItemById(String itemId) async {
    final data = await supabase
        .from('items')
        .select()
        .eq('id', itemId)
        .maybeSingle();

    if (data == null) return null;

    return Item.fromJson(data);
  }

  // ===========================================================================
  // GET IMAGES
  // ===========================================================================
  Future<List<ItemImage>> getItemImages(String itemId) async {
    final data = await supabase
        .from('item_images')
        .select()
        .eq('item_id', itemId)
        .order('position', ascending: true);

    return (data as List)
        .map<ItemImage>(
          (json) => ItemImage.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  // ===========================================================================
  // UPDATE ITEM FIELDS
  // ===========================================================================
  Future<void> updateItem(String itemId, Map<String, dynamic> updates) async {
    updates['updated_at'] = DateTime.now().toIso8601String();

    await supabase.from('items').update(updates).eq('id', itemId);
  }

  // ===========================================================================
  // DELETE A SPECIFIC IMAGE (Storage + DB)
  // ===========================================================================
  Future<void> deleteImage(String imageUrl) async {
    if (imageUrl.isEmpty) return;

    // Example public URL:
    // https://<project>.supabase.co/storage/v1/object/public/item-images/items/<itemId>/<fileName>
    // We need the internal path: 'items/<itemId>/<fileName>'
    final marker = '/item-images/';
    final idx = imageUrl.indexOf(marker);
    if (idx == -1) {
      // fallback: try to find '/public/' and take everything after bucket name
      final altMarker = '/public/';
      final altIdx = imageUrl.indexOf(altMarker);
      if (altIdx == -1) {
        // give up (avoid deleting storage) — still delete DB record to keep consistency
        await supabase.from('item_images').delete().eq('image_url', imageUrl);
        return;
      } else {
        final remainder = imageUrl.substring(altIdx + altMarker.length);
        // remainder like 'item-images/items/...'
        final afterBucket = remainder.split('/')..removeAt(0);
        final internalPath = afterBucket.join('/');
        await supabase.storage.from('item-images').remove([internalPath]);
        await supabase.from('item_images').delete().eq('image_url', imageUrl);
        return;
      }
    }

    final internalPath = imageUrl.substring(
      idx + marker.length,
    ); // items/<itemId>/<fileName>

    // Remove from storage (safe to ignore if it fails)
    try {
      await supabase.storage.from('item-images').remove([internalPath]);
    } catch (_) {
      // ignore storage deletion failure but continue to remove DB row
    }

    // Remove DB row
    await supabase.from('item_images').delete().eq('image_url', imageUrl);
  }

  // Delete image by id (fetch row first to get URL), safer for RLS policies
  Future<void> deleteImageById(String imageId) async {
    final row = await supabase
        .from('item_images')
        .select('image_url')
        .eq('id', imageId)
        .maybeSingle();
    if (row == null) return;
    final url = row['image_url'] as String?;
    if (url != null && url.isNotEmpty) {
      // Attempt storage removal using same logic as deleteImage
      final marker = '/item-images/';
      final idx = url.indexOf(marker);
      if (idx != -1) {
        final internalPath = url.substring(idx + marker.length);
        try {
          await supabase.storage.from('item-images').remove([internalPath]);
        } catch (_) {}
      }
    }
    // Always delete DB row by id (even if storage removal failed)
    await supabase.from('item_images').delete().eq('id', imageId);
  }

  // Delete all images for an item whose positions are NOT in the provided set.
  // Also removes from storage.
  Future<void> deleteImagesNotInPositions(
    String itemId,
    Set<int> allowedPositions,
  ) async {
    final data =
        await supabase
                .from('item_images')
                .select('id, image_url, position')
                .eq('item_id', itemId)
            as List<dynamic>;
    for (final row in data) {
      final pos = row['position'] as int?;
      if (pos == null || !allowedPositions.contains(pos)) {
        final id = row['id'] as String;
        final url = row['image_url'] as String?;
        if (url != null && url.isNotEmpty) {
          final marker = '/item-images/';
          final idx = url.indexOf(marker);
          if (idx != -1) {
            final internalPath = url.substring(idx + marker.length);
            try {
              await supabase.storage.from('item-images').remove([internalPath]);
            } catch (_) {}
          }
        }
        await supabase.from('item_images').delete().eq('id', id);
      }
    }
  }

  // Delete all images for an item EXCEPT the ones with ids in allowedIds.
  // Also removes the corresponding storage objects.
  Future<void> deleteImagesExceptIds(
    String itemId,
    Set<String> allowedIds,
  ) async {
    final data =
        await supabase
                .from('item_images')
                .select('id, image_url')
                .eq('item_id', itemId)
            as List<dynamic>;
    for (final row in data) {
      final id = row['id'] as String?;
      if (id == null || allowedIds.contains(id)) continue;
      final url = row['image_url'] as String?;
      if (url != null && url.isNotEmpty) {
        final marker = '/item-images/';
        final idx = url.indexOf(marker);
        if (idx != -1) {
          final internalPath = url.substring(idx + marker.length);
          try {
            await supabase.storage.from('item-images').remove([internalPath]);
          } catch (_) {}
        } else {
          // Fallback: try after '/public/' bucket name
          final altMarker = '/public/';
          final altIdx = url.indexOf(altMarker);
          if (altIdx != -1) {
            final remainder = url.substring(altIdx + altMarker.length);
            final parts = remainder.split('/')..removeAt(0); // drop bucket
            final internalPath = parts.join('/');
            try {
              await supabase.storage.from('item-images').remove([internalPath]);
            } catch (_) {}
          }
        }
      }
      await supabase.from('item_images').delete().eq('id', id);
    }
  }

  // Update position of an existing item_images row by id
  Future<void> updateItemImagePosition(String imageId, int position) async {
    await supabase
        .from('item_images')
        .update({'position': position})
        .eq('id', imageId);
  }

  // ===========================================================================
  // REPLACE ALL IMAGES (Used when user re-uploads everything)
  // ===========================================================================
  Future<void> replaceItemImages(String itemId, List<File> newImages) async {
    final oldImages = await getItemImages(itemId);

    for (final img in oldImages) {
      await deleteImage(img.imageUrl);
    }

    await uploadItemImages(itemId, newImages);
  }

  // ===========================================================================
  // UPDATE ONLY SOME IMAGES (partial update)
  //
  // - removedImages: list of ItemImage (existing DB rows) to delete
  // - newAddedImages: list of File to upload (they will be appended and inserted)
  // Returns the full, current list of ItemImage rows after the operation.
  // ===========================================================================
  Future<List<ItemImage>> updateItemImages({
    required String itemId,
    required List<ItemImage> oldImages,
    required List<File> newAddedImages,
    required List<ItemImage> removedImages,
  }) async {
    // 1) Delete requested existing images
    for (final img in removedImages) {
      await deleteImage(img.imageUrl);
    }

    // 2) Keep existing behavior for appends (legacy callers)
    if (newAddedImages.isNotEmpty) {
      await uploadItemImages(itemId, newAddedImages);
    }

    // 4) Return fresh list of images
    return await getItemImages(itemId);
  }

  // ===========================================================================
  // REORDER IMAGES: set the position value for a list of image IDs in order.
  // orderedImageIds should be a list of item_image.id in the desired order.
  // ===========================================================================
  Future<void> reorderItemImages(
    String itemId,
    List<String> orderedImageIds,
  ) async {
    for (int i = 0; i < orderedImageIds.length; i++) {
      final imgId = orderedImageIds[i];
      final pos = i + 1;
      await supabase
          .from('item_images')
          .update({'position': pos})
          .eq('id', imgId);
    }
  }

  // ===========================================================================
  // DELETE ITEM
  // ===========================================================================
  Future<void> deleteItem(String itemId) async {
    final oldImages = await getItemImages(itemId);

    for (final img in oldImages) {
      await deleteImage(img.imageUrl);
    }

    await supabase.from('items').delete().eq('id', itemId);
  }
}
