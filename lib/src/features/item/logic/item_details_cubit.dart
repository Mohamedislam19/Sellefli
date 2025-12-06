import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/item_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import 'item_details_state.dart';

class ItemDetailsCubit extends Cubit<ItemDetailsState> {
  final ItemRepository _itemRepository;
  final ProfileRepository _profileRepository;

  ItemDetailsCubit({
    required ItemRepository itemRepository,
    required ProfileRepository profileRepository,
  })  : _itemRepository = itemRepository,
        _profileRepository = profileRepository,
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
      
      // Fetch owner profile
      final owner = await _profileRepository.getProfileById(item.ownerId);
      
      emit(ItemDetailsLoaded(item: item, images: images, owner: owner));
    } catch (e) {
      emit(ItemDetailsError(e.toString()));
    }
  }
}


