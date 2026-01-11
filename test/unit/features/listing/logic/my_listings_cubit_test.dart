import 'package:bloc_test/bloc_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sellefli/src/data/local/local_item_repository.dart';
import 'package:sellefli/src/data/models/item_model.dart';
import 'package:sellefli/src/data/models/item_image_model.dart';
import 'package:sellefli/src/data/repositories/item_repository.dart';
import 'package:sellefli/src/features/listing/logic/my_listings_cubit.dart';
import 'package:sellefli/src/features/listing/logic/my_listings_state.dart';

import '../../../../helpers/test_bootstrap.dart';

class MockItemRepository extends Mock implements ItemRepository {}

class MockLocalItemRepository extends Mock implements LocalItemRepository {}

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  bootstrapUnitTests();

  late MockItemRepository itemRepository;
  late MockLocalItemRepository localRepo;
  late MockConnectivity connectivity;

  setUp(() {
    itemRepository = MockItemRepository();
    localRepo = MockLocalItemRepository();
    connectivity = MockConnectivity();
  });

  group('MyListingsCubit', () {
    blocTest<MyListingsCubit, MyListingsState>(
      'loadMyListings emits offline loaded when no connectivity',
      build: () {
        when(
          () => connectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.none]);
        when(
          () => localRepo.getCachedItems(limit: any(named: 'limit')),
        ).thenAnswer((_) async => <Item>[]);
        return MyListingsCubit(
          itemRepository: itemRepository,
          localItemRepository: localRepo,
          connectivity: connectivity,
        );
      },
      act: (cubit) => cubit.loadMyListings(),
      expect: () => [
        isA<MyListingsLoading>(),
        isA<MyListingsLoaded>().having((s) => s.isOffline, 'isOffline', true),
      ],
    );

    blocTest<MyListingsCubit, MyListingsState>(
      'loadMyListings emits online loaded when connectivity available',
      build: () {
        when(
          () => connectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.wifi]);
        when(
          () => itemRepository.getMyItems(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer((_) async => <Item>[]);
        when(
          () => localRepo.upsertLocalItem(
            item: any(named: 'item'),
            thumbnailUrl: any(named: 'thumbnailUrl'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => itemRepository.getItemImages(any()),
        ).thenAnswer((_) async => <ItemImage>[]);
        when(
          () => localRepo.replaceItemImages(any(), any()),
        ).thenAnswer((_) async {});

        return MyListingsCubit(
          itemRepository: itemRepository,
          localItemRepository: localRepo,
          connectivity: connectivity,
        );
      },
      act: (cubit) => cubit.loadMyListings(),
      expect: () => [
        isA<MyListingsLoading>(),
        isA<MyListingsLoaded>().having((s) => s.isOffline, 'isOffline', false),
      ],
    );

    blocTest<MyListingsCubit, MyListingsState>(
      'deleteItem emits deleting then success then reload',
      build: () {
        when(
          () => connectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.wifi]);
        when(() => itemRepository.deleteItem(any())).thenAnswer((_) async {});
        when(
          () => itemRepository.getMyItems(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer((_) async => <Item>[]);
        when(
          () => localRepo.upsertLocalItem(
            item: any(named: 'item'),
            thumbnailUrl: any(named: 'thumbnailUrl'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => itemRepository.getItemImages(any()),
        ).thenAnswer((_) async => <ItemImage>[]);
        when(
          () => localRepo.replaceItemImages(any(), any()),
        ).thenAnswer((_) async {});

        return MyListingsCubit(
          itemRepository: itemRepository,
          localItemRepository: localRepo,
          connectivity: connectivity,
        );
      },
      act: (cubit) => cubit.deleteItem('id'),
      expect: () => [
        isA<MyListingsDeletingItem>(),
        isA<MyListingsDeleteSuccess>(),
        isA<MyListingsLoading>(),
        isA<MyListingsLoaded>(),
      ],
    );

    test('deleteItem calls repository deleteItem with itemId', () async {
      when(
        () => connectivity.checkConnectivity(),
      ).thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(() => itemRepository.deleteItem(any())).thenAnswer((_) async {});
      when(
        () => itemRepository.getMyItems(
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer((_) async => <Item>[]);
      when(
        () => localRepo.upsertLocalItem(
          item: any(named: 'item'),
          thumbnailUrl: any(named: 'thumbnailUrl'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => itemRepository.getItemImages(any()),
      ).thenAnswer((_) async => <ItemImage>[]);
      when(
        () => localRepo.replaceItemImages(any(), any()),
      ).thenAnswer((_) async {});

      final cubit = MyListingsCubit(
        itemRepository: itemRepository,
        localItemRepository: localRepo,
        connectivity: connectivity,
      );
      addTearDown(cubit.close);

      const itemId = '550e8400-e29b-41d4-a716-446655440000';
      await cubit.deleteItem(itemId);

      verify(() => itemRepository.deleteItem(itemId)).called(1);
    });

    blocTest<MyListingsCubit, MyListingsState>(
      'deleteItem emits deleting then error when repository throws',
      build: () {
        when(
          () => connectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.wifi]);
        when(() => itemRepository.deleteItem(any())).thenThrow(Exception('boom'));

        return MyListingsCubit(
          itemRepository: itemRepository,
          localItemRepository: localRepo,
          connectivity: connectivity,
        );
      },
      act: (cubit) => cubit.deleteItem('id'),
      expect: () => [
        isA<MyListingsDeletingItem>(),
        isA<MyListingsError>().having(
          (s) => s.message,
          'message',
          contains('Failed to delete listing'),
        ),
      ],
    );
  });
}
