import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../data/models/item_model.dart';
import '../../data/models/item_image_model.dart';

class DbHelper {
  static const _dbName = 'sellefli_local.db';
  static const _dbVersion = 2;

  static const tableItems = 'local_items';
  static const tableItemImages = 'local_item_images';

  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await _createSchema(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _upgradeSchema(db, oldVersion, newVersion);
      },
    );
  }

  static Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableItems (
        id TEXT PRIMARY KEY,
        title TEXT,
        category TEXT,
        thumbnail_url TEXT,
        estimated_value REAL,
        deposit_amount REAL,
        is_available INTEGER,
        owner_id TEXT,
        created_at TEXT,
        updated_at TEXT,
        cached_at INTEGER
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableItemImages (
        id TEXT PRIMARY KEY,
        item_id TEXT,
        image_url TEXT,
        position INTEGER,
        cached_at INTEGER
      );
    ''');

    // Helpful indices for faster queries
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_local_items_cached_at ON $tableItems(cached_at);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_local_item_images_item_id ON $tableItemImages(item_id);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_local_item_images_position ON $tableItemImages(position);',
    );
  }

  static Future<void> _upgradeSchema(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // v1 -> v2: add indices and ensure tables exist
    if (oldVersion < 2) {
      await _createSchema(db);
    }
  }

  // Upsert local_items
  static Future<void> upsertLocalItem({
    required Item item,
    String? thumbnailUrl,
  }) async {
    final db = await database;
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
      tableItems,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Replace local_item_images for an item (clear then insert provided list)
  static Future<void> replaceItemImages(
    String itemId,
    List<ItemImage> images,
  ) async {
    final db = await database;
    final batch = db.batch();
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    batch.delete(tableItemImages, where: 'item_id = ?', whereArgs: [itemId]);
    for (final img in images) {
      batch.insert(tableItemImages, {
        'id': img.id,
        'item_id': itemId,
        'image_url': img.imageUrl,
        'position': img.position ?? 1,
        'cached_at': nowMs,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  static Future<void> deleteLocalItem(String itemId) async {
    final db = await database;
    final batch = db.batch();
    batch.delete(tableItemImages, where: 'item_id = ?', whereArgs: [itemId]);
    batch.delete(tableItems, where: 'id = ?', whereArgs: [itemId]);
    await batch.commit(noResult: true);
  }

  // Simple verification helpers
  static Future<Map<String, Object?>?> getLocalItem(String itemId) async {
    final db = await database;
    final rows = await db.query(
      tableItems,
      where: 'id = ?',
      whereArgs: [itemId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  static Future<List<Map<String, Object?>>> getLocalItemImages(
    String itemId,
  ) async {
    final db = await database;
    return db.query(
      tableItemImages,
      where: 'item_id = ?',
      whereArgs: [itemId],
      orderBy: 'position ASC',
    );
  }

  // Debugging: log current cached state for a given item
  static Future<void> debugLogItemCache(String itemId) async {
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
  static Future<void> debugLogAllItems() async {
    try {
      final db = await database;
      final items = await db.query(tableItems, orderBy: 'updated_at DESC');
      print('');
      print('================== LOCAL DB SNAPSHOT ==================');
      print('Total local_items: ${items.length}');
      for (final item in items) {
        final itemId = item['id'] as String? ?? 'unknown';
        final images = await db.query(
          tableItemImages,
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
