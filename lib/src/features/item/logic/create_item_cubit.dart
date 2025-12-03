import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sellefli/src/data/local/db_helper.dart';

import '../../../data/models/item_model.dart';
import '../../../data/repositories/item_repository.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:uuid/uuid.dart';

part 'create_item_state.dart';

class CreateItemCubit extends Cubit<CreateItemState> {
  final ItemRepository itemRepository;

  CreateItemCubit()
    : itemRepository = ItemRepository(Supabase.instance.client),
      super(CreateItemInitial());

  // -----------------------------------------------------------------------------
  // CREATE ITEM
  // -----------------------------------------------------------------------------
  Future<void> createItem({
    required String ownerId,
    required String title,
    required String category,
    String? description,
    double? estimatedValue,
    double? depositAmount,
    DateTime? startDate,
    DateTime? endDate,
    double? lat,
    double? lng,
    required List<File> images,
  }) async {
    try {
      emit(CreateItemLoading());

      // 1. Create an Item model instance
      final now = DateTime.now();

      final item = Item(
        id: const Uuid().v4(), // client-side UUID
        ownerId: ownerId,
        title: title,
        category: category,
        description: description,
        estimatedValue: estimatedValue,
        depositAmount: depositAmount,
        startDate: startDate,
        endDate: endDate,
        lat: lat,
        lng: lng,
        isAvailable: true,
        createdAt: now,
        updatedAt: now,
      );

      // 2. Insert item row inside Supabase
      final itemId = await itemRepository.createItem(item);

      // 3. Upload images to storage + table
      if (images.isNotEmpty) {
        await itemRepository.uploadItemImages(itemId, images);
      }

      // 4. Refresh images from Supabase and cache to local DB
      final supabaseImages = await itemRepository.getItemImages(itemId);
      final thumbUrl = supabaseImages.isNotEmpty
          ? supabaseImages.first.imageUrl
          : null;
      print('[CreateItemCubit] Local DB: upsert item ${item.id}');
      await DbHelper.upsertLocalItem(item: item, thumbnailUrl: thumbUrl);
      print(
        '[CreateItemCubit] Local DB: replace images for ${item.id} (count=${supabaseImages.length})',
      );
      await DbHelper.replaceItemImages(itemId, supabaseImages);
      // Debug dump of local cache for this item
      await DbHelper.debugLogItemCache(itemId);
      // Debug: full local DB snapshot (all items and image counts)
      await DbHelper.debugLogAllItems();

      emit(CreateItemSuccess(itemId));
    } catch (e) {
      emit(CreateItemError(e.toString()));
    }
  }
}
