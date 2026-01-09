import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sellefli/src/data/models/user_model.dart' as models;
import 'package:sellefli/src/data/repositories/booking_repository.dart';
import 'package:sellefli/src/data/repositories/profile_repository.dart';
import 'package:sellefli/src/features/profile/logic/profile_cubit.dart';
import 'package:sellefli/src/features/profile/logic/profile_state.dart';

import '../../../../helpers/test_bootstrap.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockBookingRepository extends Mock implements BookingRepository {}

void main() {
  bootstrapUnitTests();

  late MockProfileRepository profileRepository;
  late MockBookingRepository bookingRepository;

  setUp(() {
    profileRepository = MockProfileRepository();
    bookingRepository = MockBookingRepository();
  });

  group('ProfileCubit', () {
    final user = models.User(
      id: 'u1',
      username: 'name',
      createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
      updatedAt: DateTime.parse('2024-01-02T00:00:00.000Z'),
    );

    blocTest<ProfileCubit, ProfileState>(
      'loadMyProfile emits error when profile is null',
      build: () {
        when(
          () => profileRepository.getMyProfile(),
        ).thenAnswer((_) async => null);
        return ProfileCubit(
          profileRepository: profileRepository,
          bookingRepository: bookingRepository,
        );
      },
      act: (cubit) => cubit.loadMyProfile(),
      expect: () => [isA<ProfileLoading>(), isA<ProfileError>()],
    );

    blocTest<ProfileCubit, ProfileState>(
      'loadMyProfile emits loaded with transactions',
      build: () {
        when(
          () => profileRepository.getMyProfile(),
        ).thenAnswer((_) async => user);
        when(
          () => bookingRepository.getUserTransactions('u1'),
        ).thenAnswer((_) async => <Map<String, dynamic>>[]);
        return ProfileCubit(
          profileRepository: profileRepository,
          bookingRepository: bookingRepository,
        );
      },
      act: (cubit) => cubit.loadMyProfile(),
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfileLoaded>().having((s) => s.profile.id, 'id', 'u1'),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'refreshById emits loaded when profile exists',
      build: () {
        when(
          () => profileRepository.getProfileById('u2'),
        ).thenAnswer((_) async => user);
        when(
          () => bookingRepository.getUserTransactions('u2'),
        ).thenAnswer((_) async => <Map<String, dynamic>>[]);
        return ProfileCubit(
          profileRepository: profileRepository,
          bookingRepository: bookingRepository,
        );
      },
      act: (cubit) => cubit.refreshById('u2'),
      expect: () => [isA<ProfileLoading>(), isA<ProfileLoaded>()],
    );
  });
}
