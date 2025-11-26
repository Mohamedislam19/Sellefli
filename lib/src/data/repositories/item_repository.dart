import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/item_model.dart';
import '../models/item_image_model.dart';

class ItemRepository {
  final SupabaseClient supabase;

  ItemRepository(this.supabase);

  // ---------------------------------------------------------------------------
  // CREATE ITEM
  // ---------------------------------------------------------------------------
  Future<String> createItem(Item item) async {
    final response = await supabase
        .from('items')
        .insert(item.toJson())
        .select()
        .single();

    return response['id'] as String;
  }

  // ---------------------------------------------------------------------------
  // UPLOAD IMAGES
  // storage: items/<itemId>/<filename>
  // Also inserts into ITEM_IMAGES table
  // ---------------------------------------------------------------------------
  Future<void> uploadItemImages(String itemId, List<File> images) async {
    for (int i = 0; i < images.length; i++) {
      final file = images[i];
      final fileExt = file.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'items/$itemId/$fileName';

      // Upload to storage
      final storageResponse = await supabase.storage
          .from('item-images')
          .upload(filePath, file);

      if (storageResponse.isEmpty) {
        throw Exception('Failed to upload image');
      }

      // Get public URL
      final publicUrl = supabase.storage
          .from('item-images')
          .getPublicUrl(filePath);

      // Insert into ITEM_IMAGES table
      await supabase.from('item_images').insert({
        'item_id': itemId,
        'image_url': publicUrl,
        'position': i + 1,
      });
    }
  }

  // ---------------------------------------------------------------------------
  // GET ITEM BY ID
  // ---------------------------------------------------------------------------
  Future<Item?> getItemById(String id) async {
    final response = await supabase
        .from('items')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;

    return Item.fromJson(response);
  }

  // ---------------------------------------------------------------------------
  // GET ITEM IMAGES BY ITEM ID
  // ---------------------------------------------------------------------------
  Future<List<ItemImage>> getItemImages(String itemId) async {
    final response = await supabase
        .from('item_images')
        .select()
        .eq('item_id', itemId)
        .order('position', ascending: true);

    return response.map<ItemImage>((json) => ItemImage.fromJson(json)).toList();
  }

  // ---------------------------------------------------------------------------
  // UPDATE ITEM
  // ---------------------------------------------------------------------------
  Future<void> updateItem(String id, Map<String, dynamic> updates) async {
    updates['updated_at'] = DateTime.now().toIso8601String();

    await supabase.from('items').update(updates).eq('id', id);
  }

  // ---------------------------------------------------------------------------
  // DELETE A SPECIFIC IMAGE (both storage + DB)
  // ---------------------------------------------------------------------------
  Future<void> deleteImage(String imageUrl) async {
    // extract filename from public URL
    final path = imageUrl.split('/item-images/').last;

    // Delete from storage
    await supabase.storage.from('item-images').remove([path]);

    // Delete from DB table
    await supabase.from('item_images').delete().eq('image_url', imageUrl);
  }

  // ---------------------------------------------------------------------------
  // REPLACE ALL IMAGES (used during editing)
  // Deletes old images, uploads new ones
  // ---------------------------------------------------------------------------
  Future<void> replaceItemImages(String itemId, List<File> newImages) async {
    // Fetch existing images
    final oldImgs = await getItemImages(itemId);

    // Delete all old images
    for (var img in oldImgs) {
      await deleteImage(img.imageUrl);
    }

    // Upload new images
    await uploadItemImages(itemId, newImages);
  }

  // ---------------------------------------------------------------------------
  // DELETE ITEM (optional, future use)
  // Also deletes images
  // ---------------------------------------------------------------------------
  Future<void> deleteItem(String id) async {
    final oldImgs = await getItemImages(id);

    for (var img in oldImgs) {
      await deleteImage(img.imageUrl);
    }

    await supabase.from('items').delete().eq('id', id);
  }
}
