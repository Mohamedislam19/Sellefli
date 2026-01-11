import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sellefli/src/data/repositories/auth_repository.dart';
import 'package:sellefli/src/data/repositories/item_repository.dart';
import 'package:sellefli/src/features/home/logic/home_cubit.dart';
import 'package:sellefli/src/features/home/logic/home_state.dart';

import '../../../../helpers/test_bootstrap.dart';

class _MockItemRepository extends Mock implements ItemRepository {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _TestHomeCubit extends HomeCubit {
  _TestHomeCubit(super.itemRepository, super.authRepository);

  final List<bool> loadItemsRefreshArgs = <bool>[];

  void setTestState(HomeState newState) => emit(newState);

  @override
  Future<void> loadItems({bool refresh = false}) async {
    loadItemsRefreshArgs.add(refresh);
  }
}

void main() {
  setUpAll(bootstrapUnitTests);

  group('HomeCubit (unit)', () {
    late _MockItemRepository itemRepository;
    late _MockAuthRepository authRepository;

    setUp(() {
      itemRepository = _MockItemRepository();
      authRepository = _MockAuthRepository();
    });

    test('initial state has All selected', () {
      final cubit = _TestHomeCubit(itemRepository, authRepository);
      addTearDown(cubit.close);

      expect(cubit.state.selectedCategories, const ['All']);
      expect(cubit.state.searchQuery, '');
      expect(cubit.state.radius, 5.0);
      expect(cubit.state.isLocationEnabled, false);
    });

    blocTest<_TestHomeCubit, HomeState>(
      'selectCategory: selecting a specific category replaces All',
      build: () => _TestHomeCubit(itemRepository, authRepository),
      act: (cubit) => cubit.selectCategory('Electronics'),
      expect: () => [
        isA<HomeState>().having(
          (s) => s.selectedCategories,
          'selectedCategories',
          const ['Electronics'],
        ),
      ],
      verify: (cubit) {
        expect(cubit.loadItemsRefreshArgs, const [true]);
      },
    );

    blocTest<_TestHomeCubit, HomeState>(
      'selectCategory: toggling categories adds/removes and falls back to All',
      build: () => _TestHomeCubit(itemRepository, authRepository),
      act: (cubit) {
        cubit.selectCategory('Electronics');
        cubit.selectCategory('Vehicles');
        cubit.selectCategory('Electronics'); // remove
        cubit.selectCategory('Vehicles'); // remove last -> All
      },
      expect: () => [
        isA<HomeState>().having(
          (s) => s.selectedCategories,
          'selectedCategories',
          const ['Electronics'],
        ),
        isA<HomeState>().having(
          (s) => s.selectedCategories,
          'selectedCategories',
          const ['Electronics', 'Vehicles'],
        ),
        isA<HomeState>().having(
          (s) => s.selectedCategories,
          'selectedCategories',
          const ['Vehicles'],
        ),
        isA<HomeState>().having(
          (s) => s.selectedCategories,
          'selectedCategories',
          const ['All'],
        ),
      ],
      verify: (cubit) {
        expect(cubit.loadItemsRefreshArgs, const [true, true, true, true]);
      },
    );

    blocTest<_TestHomeCubit, HomeState>(
      'selectCategory: selecting All clears other categories',
      build: () => _TestHomeCubit(itemRepository, authRepository),
      act: (cubit) {
        cubit.selectCategory('Electronics');
        cubit.selectCategory('Vehicles');
        cubit.selectCategory('All');
      },
      expect: () => [
        isA<HomeState>().having(
          (s) => s.selectedCategories,
          'selectedCategories',
          const ['Electronics'],
        ),
        isA<HomeState>().having(
          (s) => s.selectedCategories,
          'selectedCategories',
          const ['Electronics', 'Vehicles'],
        ),
        isA<HomeState>().having(
          (s) => s.selectedCategories,
          'selectedCategories',
          const ['All'],
        ),
      ],
      verify: (cubit) {
        expect(cubit.loadItemsRefreshArgs, const [true, true, true]);
      },
    );

    blocTest<_TestHomeCubit, HomeState>(
      'updateSearchQuery updates state and triggers refresh load',
      build: () => _TestHomeCubit(itemRepository, authRepository),
      act: (cubit) => cubit.updateSearchQuery('camera'),
      expect: () => [
        isA<HomeState>().having((s) => s.searchQuery, 'searchQuery', 'camera'),
      ],
      verify: (cubit) {
        expect(cubit.loadItemsRefreshArgs, const [true]);
      },
    );

    blocTest<_TestHomeCubit, HomeState>(
      'updateRadius updates radius and triggers refresh only when location enabled',
      build: () {
        final cubit = _TestHomeCubit(itemRepository, authRepository);
        cubit.setTestState(
          cubit.state.copyWith(isLocationEnabled: true),
        );
        return cubit;
      },
      act: (cubit) => cubit.updateRadius(10.0),
      expect: () => [
        isA<HomeState>().having((s) => s.radius, 'radius', 10.0),
      ],
      verify: (cubit) {
        expect(cubit.loadItemsRefreshArgs, const [true]);
      },
    );

    blocTest<_TestHomeCubit, HomeState>(
      'updateRadius updates radius without triggering load when location disabled',
      build: () => _TestHomeCubit(itemRepository, authRepository),
      act: (cubit) => cubit.updateRadius(7.5),
      expect: () => [
        isA<HomeState>().having((s) => s.radius, 'radius', 7.5),
      ],
      verify: (cubit) {
        expect(cubit.loadItemsRefreshArgs, isEmpty);
      },
    );
  });
}
