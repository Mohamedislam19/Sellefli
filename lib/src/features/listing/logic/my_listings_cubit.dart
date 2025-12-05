import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/item_model.dart';
import '../../../data/repositories/item_repository.dart';
import '../../../data/local/local_item_repository.dart';
import '../../../data/local/db_helper.dart';

part 'my_listings_state.dart';

class MyListingsCubit extends Cubit<MyListingsState> {
  final ItemRepository _itemRepository;
  final LocalItemRepository _localRepo = LocalItemRepository();
  final Connectivity _connectivity;

  MyListingsCubit({ItemRepository? itemRepository, Connectivity? connectivity})
      : _itemRepository = itemRepository ?? ItemRepository(Supabase.instance.client),
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
        emit(MyListingsLoaded(items: items));
      } else {
        // Offline: read from local DB and return
        final db = await DbHelper.database;
        final rows = await db.query(
          DbHelper.tableItems,
          orderBy: 'updated_at DESC',
        );
        final items = rows.map<Item>((r) {
          // Map local row to Item using available fields
          return Item(
            id: r['id'] as String,
            ownerId: r['owner_id'] as String,
            title: r['title'] as String,
            category: r['category'] as String,
            description: null,
            estimatedValue: (r['estimated_value'] as num?)?.toDouble(),
            depositAmount: (r['deposit_amount'] as num?)?.toDouble(),
            startDate: null,
            endDate: null,
            lat: null,
            lng: null,
            isAvailable: (r['is_available'] as int?) == 1,
            createdAt: DateTime.parse((r['created_at'] as String?) ?? DateTime.now().toIso8601String()),
            updatedAt: DateTime.parse((r['updated_at'] as String?) ?? DateTime.now().toIso8601String()),
          );
        }).toList();
        emit(MyListingsLoaded(items: items));
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
