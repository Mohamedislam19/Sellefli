import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sellefli/src/data/local/db_helper.dart';
import 'package:sellefli/src/data/local/local_item_repository.dart';
import 'package:sellefli/src/data/models/item_image_model.dart';
import 'package:sellefli/src/data/models/item_model.dart';

import '../../../helpers/test_bootstrap.dart';

void main() {
  bootstrapUnitTests();

  late LocalItemRepository repository;

  setUp(() async {
    repository = LocalItemRepository();
    final db = await DbHelper.database;
    await db.delete(DbHelper.tableItemImages);
    await db.delete(DbHelper.tableItems);
  });

  Item _buildItem({required String id, List<String> images = const []}) {
    final now = DateTime.utc(2024, 1, 1);
    return Item(
      id: id,
      ownerId: 'owner-$id',
      title: 'Item $id',
      category: 'Category',
      createdAt: now,
      updatedAt: now,
      images: images,
    );
  }

  ItemImage _buildImage(String id, int position) => ItemImage(
    id: '$id-pos$position',
    itemId: id,
    imageUrl: 'http://example.com/$id/$position.png',
    position: position,
  );

  group('LocalItemRepository', () {
    test('upsertLocalItem stores item row with thumbnail', () async {
      final item = _buildItem(id: 'item-1');

      await repository.upsertLocalItem(
        item: item,
        thumbnailUrl: 'http://thumb.png',
      );

      final row = await repository.getLocalItem(item.id);
      expect(row, isNotNull);
      expect(row!['title'], equals('Item item-1'));
      expect(row['thumbnail_url'], equals('http://thumb.png'));
      expect(row['owner_id'], equals('owner-item-1'));
    });

    test(
      'replaceItemImages clears previous images before inserting new set',
      () async {
        const itemId = 'item-2';
        final db = await DbHelper.database;

        // Seed existing row to ensure replacement logic executes
        await repository.upsertLocalItem(item: _buildItem(id: itemId));
        await db.insert(DbHelper.tableItemImages, {
          'id': 'legacy',
          'item_id': itemId,
          'image_url': 'http://old.png',
          'position': 99,
          'cached_at': DateTime.now().millisecondsSinceEpoch,
        }, conflictAlgorithm: ConflictAlgorithm.replace);

        final images = [_buildImage(itemId, 1), _buildImage(itemId, 2)];
        await repository.replaceItemImages(itemId, images);

        final stored = await repository.getLocalItemImages(itemId);
        expect(stored.length, 2);
        expect(stored.first['image_url'], equals(images.first.imageUrl));
        expect(stored.last['position'], equals(2));
      },
    );

    test('deleteLocalItem removes associated images', () async {
      const itemId = 'item-3';
      final item = _buildItem(id: itemId);
      await repository.upsertLocalItem(item: item);
      await repository.replaceItemImages(itemId, [_buildImage(itemId, 1)]);

      await repository.deleteLocalItem(itemId);

      final row = await repository.getLocalItem(itemId);
      final stored = await repository.getLocalItemImages(itemId);
      expect(row, isNull);
      expect(stored, isEmpty);
    });

    test('cacheItems upserts items and caches images for each entry', () async {
      final items = [
        _buildItem(id: 'item-4', images: ['http://example.com/4/0.png']),
        _buildItem(
          id: 'item-5',
          images: ['http://example.com/5/0.png', 'http://example.com/5/1.png'],
        ),
      ];

      await repository.cacheItems(items);

      final cached = await repository.getCachedItems(limit: 10);
      expect(cached.length, 2);
      expect(cached.map((item) => item.id).toSet(), {'item-4', 'item-5'});
      expect(cached.first.id, equals('item-5'));

      final db = await DbHelper.database;
      final imagesRows = await db.query(
        DbHelper.tableItemImages,
        where: 'item_id = ?',
        whereArgs: ['item-5'],
        orderBy: 'position ASC',
      );
      expect(imagesRows.length, 2);
      expect(
        imagesRows.first['image_url'],
        equals('http://example.com/5/0.png'),
      );
    });
  });
}
