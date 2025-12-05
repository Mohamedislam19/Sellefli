import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/item_model.dart';
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
  })  : _itemRepository = itemRepository,
        _localRepo = localItemRepository,
        _connectivity = connectivity ?? Connectivity(),
        super(MyListingsInitial());

  Future<bool> _isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return result.first != ConnectivityResult.none;
  }

  Future<void> loadMyListings() async {
    emit(MyListingsLoading());
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        emit(const MyListingsError('Not authenticated'));
        return;
      }

      if (await _isOnline()) {
        // Online: fetch from Supabase, then cache locally, return fresh
        final rows = await Supabase.instance.client
            .from('items')
            .select()
            .eq('owner_id', userId)
            .order('updated_at', ascending: false) as List<dynamic>;

        final items = rows
            .map<Item>((e) => Item.fromJson(e as Map<String, dynamic>))
            .toList();

        // For each item, cache into local DB with first image as thumbnail
        for (final item in items) {
          final images = await _itemRepository.getItemImages(item.id);
          final thumb = images.isNotEmpty ? images.first.imageUrl : null;
          await _localRepo.upsertLocalItem(item: item, thumbnailUrl: thumb);
          await _localRepo.replaceItemImages(item.id, images);
        }
        emit(MyListingsLoaded(items: items, isOffline: false));
      } else {
        // Offline: read from local DB and return cached items
        final items = await _localRepo.getCachedItems(limit: 100);
        emit(MyListingsLoaded(items: items, isOffline: true));
      }
    } catch (e) {
      emit(MyListingsError(e.toString()));
    }
  }

  // Special rule: Edit Item should only navigate with itemId. Backend editing is not implemented here.
  void onEditItemTapped(String itemId) {
    emit(MyListingsNavigateToEdit(itemId));
  }
}
