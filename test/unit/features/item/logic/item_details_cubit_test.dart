import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sellefli/src/data/models/item_model.dart';
import 'package:sellefli/src/data/models/item_image_model.dart';
import 'package:sellefli/src/data/models/user_model.dart' as models;
import 'package:sellefli/src/data/repositories/item_repository.dart';
import 'package:sellefli/src/data/repositories/profile_repository.dart';
import 'package:sellefli/src/features/item/logic/item_details_cubit.dart';
import 'package:sellefli/src/features/item/logic/item_details_state.dart';

import '../../../../helpers/test_bootstrap.dart';

class MockItemRepository extends Mock implements ItemRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  bootstrapUnitTests();

  late MockItemRepository itemRepository;
  late MockProfileRepository profileRepository;

  setUp(() {
    itemRepository = MockItemRepository();
    profileRepository = MockProfileRepository();
  });

  group('ItemDetailsCubit', () {
    final item = Item(
      id: 'i1',
      ownerId: 'u1',
      title: 'Drill',
      category: 'Tools',
      createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
      updatedAt: DateTime.parse('2024-01-02T00:00:00.000Z'),
    );

    final owner = models.User(
      id: 'u1',
      username: 'owner',
      createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
      updatedAt: DateTime.parse('2024-01-02T00:00:00.000Z'),
    );

    blocTest<ItemDetailsCubit, ItemDetailsState>(
      'emits error when item not found',
      build: () {
        when(
          () => itemRepository.getItemById('i1'),
        ).thenAnswer((_) async => null);
        return ItemDetailsCubit(
          itemRepository: itemRepository,
          profileRepository: profileRepository,
        );
      },
      act: (cubit) => cubit.load('i1'),
      expect: () => [isA<ItemDetailsLoading>(), isA<ItemDetailsError>()],
    );

    blocTest<ItemDetailsCubit, ItemDetailsState>(
      'emits loaded with item, images, owner',
      build: () {
        when(
          () => itemRepository.getItemById('i1'),
        ).thenAnswer((_) async => item);
        when(() => itemRepository.getItemImages('i1')).thenAnswer(
          (_) async => <ItemImage>[
            ItemImage(id: 'img1', itemId: 'i1', imageUrl: 'a', position: 1),
            ItemImage(id: 'img2', itemId: 'i1', imageUrl: 'b', position: 2),
          ],
        );
        when(
          () => profileRepository.getProfileById('u1'),
        ).thenAnswer((_) async => owner);

        return ItemDetailsCubit(
          itemRepository: itemRepository,
          profileRepository: profileRepository,
        );
      },
      act: (cubit) => cubit.load('i1'),
      expect: () => [
        isA<ItemDetailsLoading>(),
        isA<ItemDetailsLoaded>()
            .having((s) => s.item.id, 'itemId', 'i1')
            .having((s) => s.images.length, 'images', 2)
            .having((s) => s.owner?.id, 'ownerId', 'u1'),
      ],
    );
  });
}
