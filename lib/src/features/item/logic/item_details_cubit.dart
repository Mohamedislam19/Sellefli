import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/item_model.dart';
import '../../../data/models/item_image_model.dart';
import '../../../data/repositories/item_repository.dart';

part 'item_details_state.dart';

class ItemDetailsCubit extends Cubit<ItemDetailsState> {
  final ItemRepository _itemRepository;

  ItemDetailsCubit({ItemRepository? itemRepository})
      : _itemRepository = itemRepository ?? ItemRepository(Supabase.instance.client),
        super(ItemDetailsInitial());

  Future<void> load(String itemId) async {
    emit(ItemDetailsLoading());
    try {
      final item = await _itemRepository.getItemById(itemId);
      if (item == null) {
        emit(const ItemDetailsError('Item not found'));
        return;
      }
      final images = await _itemRepository.getItemImages(itemId);
      emit(ItemDetailsLoaded(item: item, images: images));
    } catch (e) {
      emit(ItemDetailsError(e.toString()));
    }
  }
}
