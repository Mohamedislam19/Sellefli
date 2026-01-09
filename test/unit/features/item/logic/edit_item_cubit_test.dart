import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sellefli/src/data/models/item_image_model.dart';
import 'package:sellefli/src/data/models/item_model.dart';
import 'package:sellefli/src/data/repositories/item_repository.dart';
import 'package:sellefli/src/features/item/logic/edit_item_cubit.dart';

import '../../../../helpers/test_bootstrap.dart';

class MockItemRepository extends Mock implements ItemRepository {}

void main() {
  setUpAll(bootstrapUnitTests);

  group('EditItemCubit (unit)', () {
    late MockItemRepository repo;

    setUp(() {
      repo = MockItemRepository();
    });

    blocTest<EditItemCubit, EditItemState>(
      'loadItem emits loading -> loaded with slots',
      build: () {
        when(() => repo.getItemById(any())).thenAnswer(
          (_) async => Item(
            id: 'i1',
            ownerId: 'u1',
            title: 't',
            category: 'c',
            createdAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
            updatedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
          ),
        );
        when(() => repo.getItemImages(any())).thenAnswer(
          (_) async => [
            ItemImage(id: 'img2', itemId: 'i1', imageUrl: 'u2', position: 2),
          ],
        );
        return EditItemCubit(itemRepository: repo);
      },
      act: (cubit) => cubit.loadItem('i1'),
      expect: () => [isA<EditItemLoading>(), isA<EditItemLoaded>()],
      verify: (cubit) {
        final loaded = cubit.state as dynamic;
        final slots = loaded.slots as List;
        expect(slots, hasLength(3));
        expect((slots[0] as dynamic).position, 1);
        expect((slots[1] as dynamic).position, 2);
        expect(((slots[1] as dynamic).original as ItemImage).id, 'img2');
        expect((slots[2] as dynamic).position, 3);
      },
    );

    blocTest<EditItemCubit, EditItemState>(
      'loadItem emits error when item not found',
      build: () {
        when(() => repo.getItemById(any())).thenAnswer((_) async => null);
        return EditItemCubit(itemRepository: repo);
      },
      act: (cubit) => cubit.loadItem('missing'),
      expect: () => [
        isA<EditItemLoading>(),
        isA<EditItemError>().having(
          (s) => (s as EditItemError).message,
          'message',
          'Item not found',
        ),
      ],
    );

    test('swapSlots updates positions and emits loaded', () async {
      when(() => repo.getItemById(any())).thenAnswer(
        (_) async => Item(
          id: 'i1',
          ownerId: 'u1',
          title: 't',
          category: 'c',
          createdAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
          updatedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        ),
      );
      when(() => repo.getItemImages(any())).thenAnswer(
        (_) async => [
          ItemImage(id: 'img1', itemId: 'i1', imageUrl: 'u1', position: 1),
          ItemImage(id: 'img2', itemId: 'i1', imageUrl: 'u2', position: 2),
        ],
      );

      final cubit = EditItemCubit(itemRepository: repo);
      addTearDown(cubit.close);

      await cubit.loadItem('i1');
      expect(cubit.state, isA<EditItemLoaded>());

      await cubit.swapSlots(0, 1);
      expect(cubit.state, isA<EditItemLoaded>());

      final loaded = cubit.state as dynamic;
      final slots = loaded.slots as List;
      expect((slots[0] as dynamic).position, 1);
      expect((slots[1] as dynamic).position, 2);

      // The originals should have swapped positions.
      final first = slots[0] as dynamic;
      final second = slots[1] as dynamic;
      expect((first.original as ItemImage).id, 'img2');
      expect((second.original as ItemImage).id, 'img1');
    });

    test('removeImageAt clears slot and emits loaded', () async {
      when(() => repo.getItemById(any())).thenAnswer(
        (_) async => Item(
          id: 'i1',
          ownerId: 'u1',
          title: 't',
          category: 'c',
          createdAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
          updatedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        ),
      );
      when(() => repo.getItemImages(any())).thenAnswer(
        (_) async => [
          ItemImage(id: 'img1', itemId: 'i1', imageUrl: 'u1', position: 1),
        ],
      );

      final cubit = EditItemCubit(itemRepository: repo);
      addTearDown(cubit.close);

      await cubit.loadItem('i1');
      expect(cubit.state, isA<EditItemLoaded>());

      await cubit.removeImageAt(0);
      expect(cubit.state, isA<EditItemLoaded>());

      final loaded = cubit.state as dynamic;
      final slots = loaded.slots as List;
      final slot0 = slots[0] as dynamic;
      expect(slot0.original, isNull);
      expect(slot0.file, isNull);
    });
  });
}
