import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/item_model.dart';
import '../models/item_image_model.dart';

class ItemRepository {
  final SupabaseClient supabase;

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
  // ===========================================================================
  Future<void> uploadItemImages(String itemId, List<File> images) async {
    for (int i = 0; i < images.length; i++) {
      final file = images[i];
      final ext = file.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      final storagePath = 'items/$itemId/$fileName';

      // Upload to storage
      final uploadResponse = await supabase.storage
          .from('item-images')
          .upload(storagePath, file);

      if (uploadResponse.isEmpty) {
        throw Exception("Image upload failed");
      }

      // Public URL
      final publicUrl = supabase.storage
          .from('item-images')
          .getPublicUrl(storagePath);

      // Insert DB record
      await supabase.from('item_images').insert({
        'item_id': itemId,
        'image_url': publicUrl,
        'position': i + 1,
      });
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
        .order('position');

    return data.map<ItemImage>((json) => ItemImage.fromJson(json)).toList();
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
    // Storage public URL → internal path
    // ignore: unused_local_variable
    final bucketPrefix = supabase.storage
        .from('item-images')
        .getPublicUrl('')
        .replaceAll('/storage/v1/object/public/item-images/', '');

    final internalPath = imageUrl.replaceFirst(
      supabase.storage
          .from('item-images')
          .getPublicUrl('')
          .replaceAll('%2F', '/'),
      '',
    );

    // Remove from storage
    await supabase.storage.from('item-images').remove([internalPath]);

    // Remove DB row
    await supabase.from('item_images').delete().eq('image_url', imageUrl);
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
  // ===========================================================================
  Future<void> updateItemImages({
    required String itemId,
    required List<ItemImage> oldImages,
    required List<File> newAddedImages,
    required List<ItemImage> removedImages,
  }) async {
    // Remove deleted images
    for (final img in removedImages) {
      await deleteImage(img.imageUrl);
    }

    // Add new ones
    if (newAddedImages.isNotEmpty) {
      await uploadItemImages(itemId, newAddedImages);
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
