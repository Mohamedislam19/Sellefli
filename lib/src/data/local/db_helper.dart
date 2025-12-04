// ignore_for_file: unused_import

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
}
