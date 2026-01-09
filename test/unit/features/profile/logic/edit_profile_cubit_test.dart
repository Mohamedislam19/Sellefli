import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sellefli/src/data/models/user_model.dart';
import 'package:sellefli/src/data/repositories/profile_repository.dart';
import 'package:sellefli/src/features/profile/logic/edit_profile_cubit.dart';
import 'package:sellefli/src/features/profile/logic/edit_profile_state.dart';

import '../../../../helpers/test_bootstrap.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  setUpAll(bootstrapUnitTests);

  group('EditProfileCubit (unit)', () {
    late MockProfileRepository repo;

    setUp(() {
      repo = MockProfileRepository();
    });

    blocTest<EditProfileCubit, EditProfileState>(
      'emits saving -> success when updateProfile returns user (no avatar)',
      build: () {
        when(
          () => repo.updateProfile(
            username: any(named: 'username'),
            phone: any(named: 'phone'),
            avatarUrl: any(named: 'avatarUrl'),
          ),
        ).thenAnswer(
          (_) async => User(
            id: 'u1',
            username: 'name',
            email: 'u@e.com',
            phone: '12345678',
            createdAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
            updatedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
          ),
        );
        return EditProfileCubit(profileRepository: repo);
      },
      act: (cubit) => cubit.submit(username: 'name'),
      expect: () => [isA<EditProfileSaving>(), isA<EditProfileSuccess>()],
    );

    blocTest<EditProfileCubit, EditProfileState>(
      'emits saving -> error when updateProfile returns null',
      build: () {
        when(
          () => repo.updateProfile(
            username: any(named: 'username'),
            phone: any(named: 'phone'),
            avatarUrl: any(named: 'avatarUrl'),
          ),
        ).thenAnswer((_) async => null);
        return EditProfileCubit(profileRepository: repo);
      },
      act: (cubit) => cubit.submit(username: 'name'),
      expect: () => [isA<EditProfileSaving>(), isA<EditProfileError>()],
    );

    blocTest<EditProfileCubit, EditProfileState>(
      'emits error when avatar upload returns empty string',
      build: () {
        when(() => repo.uploadAvatar(any())).thenAnswer((_) async => '');
        return EditProfileCubit(profileRepository: repo);
      },
      act: (cubit) => cubit.submit(avatarFile: File('fake.png')),
      expect: () => [
        isA<EditProfileSaving>(),
        isA<EditProfileError>().having(
          (s) => s.message,
          'message',
          'Failed to upload avatar image',
        ),
      ],
    );

    blocTest<EditProfileCubit, EditProfileState>(
      'maps duplicate phone errors to user-friendly message',
      build: () {
        when(
          () => repo.updateProfile(
            username: any(named: 'username'),
            phone: any(named: 'phone'),
            avatarUrl: any(named: 'avatarUrl'),
          ),
        ).thenThrow(
          Exception('duplicate key value violates unique constraint phone'),
        );
        return EditProfileCubit(profileRepository: repo);
      },
      act: (cubit) => cubit.submit(phone: '12345678'),
      expect: () => [
        isA<EditProfileSaving>(),
        isA<EditProfileError>().having(
          (s) => s.message,
          'message',
          'This phone number is already in use',
        ),
      ],
    );
  });
}
