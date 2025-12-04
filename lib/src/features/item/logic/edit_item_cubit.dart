// ignore_for_file: unused_import, unused_local_variable, unused_element_parameter, library_private_types_in_public_api, avoid_print

import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:meta/meta.dart';

import '../../../data/models/item_image_model.dart';
import '../../../data/models/item_model.dart';
import '../../../data/repositories/item_repository.dart';
import '../../../data/local/local_item_repository.dart';

part 'edit_item_state.dart';

class _EditableImageSlot {
  ItemImage? original; // existing DB image
  XFile? file; // newly picked local file
  int position; // 1-based

  _EditableImageSlot({this.original, this.file, required this.position});

  bool get isEmpty => original == null && file == null;
  bool get isOriginal => original != null && file == null;
  bool get isNewFile => file != null;
}

class EditItemCubit extends Cubit<EditItemState> {
  final ItemRepository itemRepository;
  final LocalItemRepository _localRepo = LocalItemRepository();
  // Match UI and business rule: maximum 3 images
  static const int maxImages = 3;

  late String _itemId;
  Item? _item;
  List<_EditableImageSlot> _slots = [];
  final Set<String> _removedOriginalIds = <String>{};

  EditItemCubit({required this.itemRepository}) : super(EditItemInitial());

  // Public getters
  Item? get item => _item;

  /// visuals: list of XFile | String | null in slot order for the UI
  List<Object?> get visuals => _slots
      .map<Object?>(
        (s) => s.isNewFile
            ? s.file!
            : (s.isOriginal ? s.original!.imageUrl : null),
      )
      .toList();

  List<_EditableImageSlot> get slots => List.unmodifiable(_slots);

  /// Load item and build slots preserving positions
  Future<void> loadItem(String itemId) async {
    emit(EditItemLoading());
    try {
      _itemId = itemId;
      final fetchedItem = await itemRepository.getItemById(itemId);
      if (fetchedItem == null) {
        emit(EditItemError('Item not found'));
        return;
      }
      _item = fetchedItem;

      final images = await itemRepository.getItemImages(itemId);

      // initialize slots
      _slots = List.generate(
        maxImages,
        (i) => _EditableImageSlot(position: i + 1),
      );
      for (final img in images) {
        final posIndex = (img.position ?? 1) - 1;
        if (posIndex >= 0 && posIndex < maxImages) {
          _slots[posIndex] = _EditableImageSlot(
            original: img,
            position: posIndex + 1,
          );
        }
      }

      emit(EditItemLoaded(item: _item!, slots: List.unmodifiable(_slots)));
    } catch (e) {
      emit(EditItemError('Failed to load item: ${e.toString()}'));
    }
  }

  /// Pick an image into a specific slot
  Future<void> pickImageForSlot(int slotIndex, XFile picked) async {
    if (slotIndex < 0 || slotIndex >= maxImages) return;
    final slot = _slots[slotIndex];

    if (slot.original != null) {
      print(
        '[EditItemCubit] pickImageForSlot: slot=${slotIndex + 1} replacing original id=${slot.original!.id}',
      );
      _removedOriginalIds.add(slot.original!.id);
      slot.original = null;
    }
    print(
      '[EditItemCubit] pickImageForSlot: slot=${slotIndex + 1} new file name=${picked.name}',
    );
    slot.file = picked;

    emit(EditItemLoaded(item: _item!, slots: List.unmodifiable(_slots)));
  }

  /// Remove image at slot (either original or new file)
  Future<void> removeImageAt(int slotIndex) async {
    if (slotIndex < 0 || slotIndex >= maxImages) return;
    final slot = _slots[slotIndex];
    if (slot.original != null) {
      print(
        '[EditItemCubit] removeImageAt: slot=${slotIndex + 1} marking original id=${slot.original!.id} for deletion',
      );
      _removedOriginalIds.add(slot.original!.id);
    }
    if (slot.file != null) {
      print(
        '[EditItemCubit] removeImageAt: slot=${slotIndex + 1} clearing new file ${slot.file!.name}',
      );
    }
    slot.original = null;
    slot.file = null;
    emit(EditItemLoaded(item: _item!, slots: List.unmodifiable(_slots)));
  }

  /// Swap two slots (for reordering)
  Future<void> swapSlots(int a, int b) async {
    if (a < 0 || a >= maxImages || b < 0 || b >= maxImages) return;
    final tmp = _slots[a];
    _slots[a] = _slots[b];
    _slots[b] = tmp;
    // refresh positions
    for (int i = 0; i < _slots.length; i++) {
      _slots[i].position = i + 1;
    }
    emit(EditItemLoaded(item: _item!, slots: List.unmodifiable(_slots)));
  }

  /// Update item fields and images
  Future<void> updateItem({
    required String title,
    required String category,
    String? description,
    double? estimatedValue,
    double? depositAmount,
    DateTime? startDate,
    DateTime? endDate,
    double? lat,
    double? lng,
  }) async {
    emit(EditItemSaving());
    try {
      print('[EditItemCubit] updateItem: start for itemId=$_itemId');
      // 1) Update item row
      final updates = <String, dynamic>{
        'title': title,
        'category': category,
        'description': description,
        'estimated_value': estimatedValue,
        'deposit_amount': depositAmount,
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'lat': lat,
        'lng': lng,
      }..removeWhere((k, v) => v == null);

      await itemRepository.updateItem(_itemId, updates);
      print('[EditItemCubit] updateItem: item fields updated');

      // 2) Image sync (simple and deterministic):
      // - Delete images explicitly marked as removed (including those replaced)
      // - Compact remaining originals to the left (positions 1..n)
      // - Append new images at the end (up to maxImages)

      // 2.a) Delete removed originals by id
      for (final removedId in _removedOriginalIds) {
        try {
          print(
            '[EditItemCubit] updateItem: deleting marked image id=$removedId',
          );
          await itemRepository.deleteImageById(removedId);
          print('[EditItemCubit] updateItem: deleted id=$removedId');
        } catch (e) {
          print(
            '[EditItemCubit] updateItem: ERROR deleting id=$removedId -> ${e.toString()}',
          );
        }
      }

      // 2.b) Gather kept originals in slot order and compact to left
      final List<ItemImage> keptOriginals = [];
      for (final slot in _slots) {
        if (slot.isOriginal) keptOriginals.add(slot.original!);
      }
      int nextPos = 1;
      for (final img in keptOriginals) {
        if ((img.position ?? -1) != nextPos) {
          try {
            print(
              '[EditItemCubit] updateItem: move original id=${img.id} from pos=${img.position} to pos=$nextPos',
            );
            await itemRepository.updateItemImagePosition(img.id, nextPos);
            print(
              '[EditItemCubit] updateItem: moved id=${img.id} to pos=$nextPos',
            );
          } catch (_) {}
        }
        nextPos++;
      }

      // 2.c) Append new images at the end
      int uploadFailures = 0;
      final List<String> uploadErrors = [];
      final Set<String> newUploadedIds = <String>{};
      for (final slot in _slots) {
        if (slot.isNewFile) {
          if (nextPos <= maxImages) {
            try {
              print(
                '[EditItemCubit] updateItem: uploading new file name=${slot.file!.name} to pos=$nextPos',
              );
              final inserted = await itemRepository.uploadXFileAtPosition(
                _itemId,
                slot.file!,
                nextPos,
              );
              newUploadedIds.add(inserted.id);
              print(
                '[EditItemCubit] updateItem: uploaded id=${inserted.id} to pos=$nextPos',
              );
              nextPos++;
            } catch (e) {
              uploadFailures++;
              uploadErrors.add('Append pos $nextPos failed: ${e.toString()}');
              print(
                '[EditItemCubit] updateItem: ERROR upload to pos=$nextPos -> ${e.toString()}',
              );
            }
          } else {
            uploadFailures++;
            uploadErrors.add(
              'Too many images: cannot append more than $maxImages',
            );
            print(
              '[EditItemCubit] updateItem: skip upload; already at maxImages=$maxImages',
            );
          }
        }
      }

      // 2.d) Final storage & DB cleanup: remove any images not in kept originals + new uploads
      final Set<String> keptIds = <String>{}
        ..addAll(keptOriginals.map((e) => e.id))
        ..addAll(newUploadedIds);
      print('[EditItemCubit] updateItem: final keptIds=${keptIds.join(', ')}');
      try {
        await itemRepository.deleteImagesExceptIds(_itemId, keptIds);
        print(
          '[EditItemCubit] updateItem: cleanup removed non-kept images complete',
        );
      } catch (e) {
        print(
          '[EditItemCubit] updateItem: ERROR during cleanup deleteImagesExceptIds -> ${e.toString()}',
        );
      }

      // Clear removed tracker after application
      _removedOriginalIds.clear();
      print(
        '[EditItemCubit] updateItem: cleared removed ids, refreshing item and images',
      );

      final refreshedItem = await itemRepository.getItemById(_itemId);
      final refreshedImages = await itemRepository.getItemImages(_itemId);

      _slots = List.generate(
        maxImages,
        (i) => _EditableImageSlot(position: i + 1),
      );
      for (final img in refreshedImages) {
        final posIndex = (img.position ?? 1) - 1;
        if (posIndex >= 0 && posIndex < maxImages) {
          _slots[posIndex] = _EditableImageSlot(
            original: img,
            position: posIndex + 1,
          );
        }
      }
      _item = refreshedItem;

      // Update local cache to reflect latest state
      if (refreshedItem != null) {
        final thumbUrl = refreshedImages.isNotEmpty
            ? refreshedImages.first.imageUrl
            : null;
        print('[EditItemCubit] Local DB: upsert item ${refreshedItem.id}');
        await _localRepo.upsertLocalItem(
          item: refreshedItem,
          thumbnailUrl: thumbUrl,
        );
        print(
          '[EditItemCubit] Local DB: replace images for ${refreshedItem.id} (count=${refreshedImages.length})',
        );
        await _localRepo.replaceItemImages(_itemId, refreshedImages);
        await _localRepo.debugLogItemCache(_itemId);
        await _localRepo.debugLogAllItems();
      }

      if (uploadFailures > 0) {
        emit(
          EditItemError(
            'Updated, but $uploadFailures image(s) failed.\n${uploadErrors.join('\n')}',
          ),
        );
        print(
          '[EditItemCubit] updateItem: finished with failures=$uploadFailures',
        );
      } else {
        emit(EditItemSuccess());
        print('[EditItemCubit] updateItem: success');
      }
    } catch (e) {
      print('[EditItemCubit] updateItem: FATAL ${e.toString()}');
      emit(EditItemError('Failed to update item: ${e.toString()}'));
    }
  }
}
