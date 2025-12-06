// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps

import 'package:sqflite/sqflite.dart';

import 'db_helper.dart';
import '../../data/models/item_model.dart';
import '../../data/models/item_image_model.dart';

class LocalItemRepository {
  // Upsert local_items
  Future<void> upsertLocalItem({
    required Item item,
    String? thumbnailUrl,
  }) async {
    final db = await DbHelper.database;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final data = {
      'id': item.id,
      'title': item.title,
      'category': item.category,
      'thumbnail_url': thumbnailUrl,
      'estimated_value': item.estimatedValue,
      'deposit_amount': item.depositAmount,
      'is_available': item.isAvailable == true ? 1 : 0,
      'owner_id': item.ownerId,
      'created_at': item.createdAt.toIso8601String(),
      'updated_at': item.updatedAt.toIso8601String(),
      'cached_at': nowMs,
    };

    await db.insert(
      DbHelper.tableItems,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Replace local_item_images for an item (clear then insert provided list)
  Future<void> replaceItemImages(String itemId, List<ItemImage> images) async {
    final db = await DbHelper.database;
    final batch = db.batch();
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    batch.delete(
      DbHelper.tableItemImages,
      where: 'item_id = ?',
      whereArgs: [itemId],
    );
    for (final img in images) {
      batch.insert(DbHelper.tableItemImages, {
        'id': img.id,
        'item_id': itemId,
        'image_url': img.imageUrl,
        'position': img.position ?? 1,
        'cached_at': nowMs,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> deleteLocalItem(String itemId) async {
    final db = await DbHelper.database;
    final batch = db.batch();
    batch.delete(
      DbHelper.tableItemImages,
      where: 'item_id = ?',
      whereArgs: [itemId],
    );
    batch.delete(DbHelper.tableItems, where: 'id = ?', whereArgs: [itemId]);
    await batch.commit(noResult: true);
  }

  // Simple verification helpers
  Future<Map<String, Object?>?> getLocalItem(String itemId) async {
    final db = await DbHelper.database;
    final rows = await db.query(
      DbHelper.tableItems,
      where: 'id = ?',
      whereArgs: [itemId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<List<Map<String, Object?>>> getLocalItemImages(String itemId) async {
    final db = await DbHelper.database;
    return db.query(
      DbHelper.tableItemImages,
      where: 'item_id = ?',
      whereArgs: [itemId],
      orderBy: 'position ASC',
    );
  }

  // Get cached items for home feed
  Future<List<Item>> getCachedItems({int limit = 10}) async {
    final db = await DbHelper.database;
    final rows = await db.query(
      DbHelper.tableItems,
      orderBy: 'cached_at DESC',
      limit: limit,
    );

    List<Item> items = [];
    for (var row in rows) {
      // Fetch images for each item
      final imageRows = await getLocalItemImages(row['id'] as String);
      final images = imageRows
          .map((img) => img['image_url'] as String)
          .toList();

      items.add(
        Item(
          id: row['id'] as String,
          ownerId: row['owner_id'] as String,
          title: row['title'] as String,
          category: row['category'] as String,
          estimatedValue: (row['estimated_value'] as num?)?.toDouble(),
          depositAmount: (row['deposit_amount'] as num?)?.toDouble(),
          isAvailable: (row['is_available'] as int) == 1,
          createdAt: DateTime.parse(row['created_at'] as String),
          updatedAt: DateTime.parse(row['updated_at'] as String),
          images: images,
        ),
      );
    }
    return items;
  }

  // Cache a list of items (clears old cache first if needed, or just upserts)
  Future<void> cacheItems(List<Item> items) async {
    // For simplicity, we can just upsert them.
    // If we want to strictly keep only 10, we might want to clear the table first
    // or delete old ones. For now, let's just upsert the new ones.
    for (var item in items) {
      await upsertLocalItem(
        item: item,
        thumbnailUrl: item.images.isNotEmpty ? item.images.first : null,
      );

      // Also cache images
      if (item.images.isNotEmpty) {
        final db = await DbHelper.database;
        final batch = db.batch();
        // Delete old images for this item
        batch.delete(
          DbHelper.tableItemImages,
          where: 'item_id = ?',
          whereArgs: [item.id],
        );

        for (int i = 0; i < item.images.length; i++) {
          batch.insert(DbHelper.tableItemImages, {
            'id': '${item.id}_$i', // Generate a simple ID
            'item_id': item.id,
            'image_url': item.images[i],
            'position': i,
            'cached_at': DateTime.now().millisecondsSinceEpoch,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
        await batch.commit(noResult: true);
      }
    }
  }

  // Debugging: log current cached state for a given item
  Future<void> debugLogItemCache(String itemId) async {
    try {
      final item = await getLocalItem(itemId);
      final images = await getLocalItemImages(itemId);
      print('[LOCAL DB] itemId=$itemId');
      if (item == null) {
        print('[LOCAL DB] local_items: NOT FOUND');
      } else {
        print(
          '[LOCAL DB] local_items: id=${item['id']}, title=${item['title']}, category=${item['category']}, is_available=${item['is_available']}, updated_at=${item['updated_at']}, cached_at=${item['cached_at']}, thumbnail_url=${item['thumbnail_url']}',
        );
      }
      print('[LOCAL DB] local_item_images: count=${images.length}');
      for (final row in images) {
        print(
          '[LOCAL DB]  • id=${row['id']}, position=${row['position']}, url=${row['image_url']}, cached_at=${row['cached_at']}',
        );
      }
    } catch (e) {
      print('[LOCAL DB] debugLogItemCache error: ${e.toString()}');
    }
  }

  // Debugging: log all items and per-item image counts
  Future<void> debugLogAllItems() async {
    try {
      final db = await DbHelper.database;
      final items = await db.query(
        DbHelper.tableItems,
        orderBy: 'updated_at DESC',
      );
      print('');
      print('================== LOCAL DB SNAPSHOT ==================');
      print('Total local_items: ${items.length}');
      for (final item in items) {
        final itemId = item['id'] as String? ?? 'unknown';
        final images = await db.query(
          DbHelper.tableItemImages,
          where: 'item_id = ?',
          whereArgs: [itemId],
          orderBy: 'position ASC',
        );
        final title = item['title'];
        final category = item['category'];
        final isAvailable = item['is_available'];
        final updatedAt = item['updated_at'];
        final thumb = item['thumbnail_url'];
        print('— Item ${itemId}: "${title}" [${category}]');
        print(
          '    • available=${isAvailable}  • images=${images.length}  • updated_at=${updatedAt}',
        );
        print('    • thumb=${thumb}');
        for (final row in images) {
          print(
            '      ◦ [${row['position']}] ${row['id']}  url=${row['image_url']}',
          );
        }
      }
      print('=======================================================');
      print('');
    } catch (e) {
      print('[LOCAL DB] debugLogAllItems error: ${e.toString()}');
    }
  }
}


