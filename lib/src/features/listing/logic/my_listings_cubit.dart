import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/item_repository.dart';
import '../../../data/local/local_item_repository.dart';
import 'my_listings_state.dart';

class MyListingsCubit extends Cubit<MyListingsState> {
  final ItemRepository _itemRepository;
  final LocalItemRepository _localRepo;
  final Connectivity _connectivity;

  MyListingsCubit({
    required ItemRepository itemRepository,
    required LocalItemRepository localItemRepository,
    Connectivity? connectivity,
  }) : _itemRepository = itemRepository,
       _localRepo = localItemRepository,
       _connectivity = connectivity ?? Connectivity(),
       super(MyListingsInitial());

  Future<bool> _isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return result.first != ConnectivityResult.none;
  }

  Future<void> loadMyListings() async {
    if (isClosed) return;
    emit(MyListingsLoading());
    try {
      if (await _isOnline()) {
        // Online: fetch from Django API, then cache locally
        final items = await _itemRepository.getMyItems(page: 1, pageSize: 100);

        if (isClosed) return;

        // Cache items locally for offline use
        for (final item in items) {
          final thumb = item.images.isNotEmpty ? item.images.first : null;
          await _localRepo.upsertLocalItem(item: item, thumbnailUrl: thumb);
          // Also cache the images
          final images = await _itemRepository.getItemImages(item.id);
          await _localRepo.replaceItemImages(item.id, images);
        }
        
        if (isClosed) return;
        emit(MyListingsLoaded(items: items, isOffline: false));
      } else {
        // Offline: read from local DB and return cached items
        final items = await _localRepo.getCachedItems(limit: 100);
        if (isClosed) return;
        emit(MyListingsLoaded(items: items, isOffline: true));
      }
    } catch (e) {
      if (isClosed) return;
      emit(MyListingsError(e.toString()));
    }
  }

  // Special rule: Edit Item should only navigate with itemId. Backend editing is not implemented here.
  void onEditItemTapped(String itemId) {
    if (isClosed) return;
    emit(MyListingsNavigateToEdit(itemId));
  }

  Future<void> deleteItem(String itemId) async {
    if (isClosed) return;
    emit(MyListingsDeletingItem(itemId));
    try {
      await _itemRepository.deleteItem(itemId);
      if (isClosed) return;
      emit(MyListingsDeleteSuccess(itemId));
      // Reload listings after successful deletion
      await loadMyListings();
    } catch (e) {
      if (isClosed) return;
      emit(MyListingsError('Failed to delete listing: ${e.toString()}'));
    }
  }
}
