import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sellefli/src/data/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder {}
class MockUser extends Mock implements User {}
class MockAuthResponse extends Mock implements AuthResponse {}

void main() {
  late AuthRepository authRepository;
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  late MockSupabaseQueryBuilder mockSupabaseQueryBuilder;
  late MockPostgrestFilterBuilder mockPostgrestFilterBuilder;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    mockSupabaseQueryBuilder = MockSupabaseQueryBuilder();
    mockPostgrestFilterBuilder = MockPostgrestFilterBuilder();

    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    when(() => mockSupabaseClient.from(any())).thenReturn(mockSupabaseQueryBuilder);
    
    // Default mocks for query builder chains
    when(() => mockSupabaseQueryBuilder.select(any())).thenReturn(mockPostgrestFilterBuilder);
    when(() => mockPostgrestFilterBuilder.eq(any(), any())).thenReturn(mockPostgrestFilterBuilder);
    when(() => mockPostgrestFilterBuilder.maybeSingle()).thenAnswer((_) async => null);
    when(() => mockSupabaseQueryBuilder.insert(any())).thenAnswer((_) async => []);

    authRepository = AuthRepository(supabase: mockSupabaseClient);
  });

  group('AuthRepository', () {
    const email = 'test@example.com';
    const password = 'password123';
    const username = 'testuser';
    const phone = '1234567890';
    const userId = 'user-id-123';

    test('currentUser returns user from supabase auth', () {
      final mockUser = MockUser();
      when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);

      expect(authRepository.currentUser, mockUser);
    });

    group('signUp', () {
      test('throws exception if email already exists', () async {
        // Mock email check finding a user
        when(() => mockPostgrestFilterBuilder.eq('email', email)).thenReturn(mockPostgrestFilterBuilder);
        // We need to be specific about the maybeSingle call that follows the email check
        // However, since we return the same mock builder, we have to control the sequence or arguments carefully.
        // In the repo:
        // 1. .eq('email', email).maybeSingle()
        // 2. .eq('phone', phone).maybeSingle()
        
        // Let's just mock the first call to return data
        when(() => mockPostgrestFilterBuilder.maybeSingle()).thenAnswer((_) async => {'id': 'existing-id'});

        expect(
          () => authRepository.signUp(
            email: email,
            password: password,
            username: username,
            phone: phone,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('email is already registered'),
          )),
        );
      });

      test('throws exception if phone already exists', () async {
        // We need to differentiate between the two calls.
        // Since we are using the same mock object for the builder, it's stateful or we need different mocks.
        // A better approach is to use `when` with specific argument matchers if possible, 
        // but the builder pattern makes it hard because the intermediate object is the same.
        
        // Let's create two different filter builders for the two different chains?
        // But `select` is called on `mockSupabaseQueryBuilder` both times.
        
        // We can use `answers` to return different values on subsequent calls?
        // Or better, just verify that if the first one returns null, and second returns value, it throws.
        
        // Let's try to mock specific sequences if possible, or just rely on the fact that we can change the behavior 
        // of `maybeSingle` based on previous calls? No, mocktail doesn't support stateful mocks easily like that.
        
        // Let's assume for this test that we can't easily distinguish without more complex mocking.
        // We will skip strict mocking of the distinction and just say "if a check fails".
        // Actually, we can mock `eq` to return different builders!
        
        final emailFilterBuilder = MockPostgrestFilterBuilder();
        final phoneFilterBuilder = MockPostgrestFilterBuilder();
        
        when(() => mockSupabaseQueryBuilder.select(any())).thenReturn(mockPostgrestFilterBuilder);
        
        // When eq is called with email, return email builder
        when(() => mockPostgrestFilterBuilder.eq('email', email)).thenReturn(emailFilterBuilder);
        // When eq is called with phone, return phone builder
        when(() => mockPostgrestFilterBuilder.eq('phone', phone)).thenReturn(phoneFilterBuilder);
        
        // Email not found
        when(() => emailFilterBuilder.maybeSingle()).thenAnswer((_) async => null);
        // Phone found
        when(() => phoneFilterBuilder.maybeSingle()).thenAnswer((_) async => {'id': 'existing-id'});

        expect(
          () => authRepository.signUp(
            email: email,
            password: password,
            username: username,
            phone: phone,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('phone number is already registered'),
          )),
        );
      });

      test('calls signUp and creates profile if checks pass', () async {
        final emailFilterBuilder = MockPostgrestFilterBuilder();
        final phoneFilterBuilder = MockPostgrestFilterBuilder();
        
        when(() => mockSupabaseQueryBuilder.select(any())).thenReturn(mockPostgrestFilterBuilder);
        when(() => mockPostgrestFilterBuilder.eq('email', email)).thenReturn(emailFilterBuilder);
        when(() => mockPostgrestFilterBuilder.eq('phone', phone)).thenReturn(phoneFilterBuilder);
        
        when(() => emailFilterBuilder.maybeSingle()).thenAnswer((_) async => null);
        when(() => phoneFilterBuilder.maybeSingle()).thenAnswer((_) async => null);

        final mockAuthResponse = MockAuthResponse();
        final mockUser = MockUser();
        when(() => mockUser.id).thenReturn(userId);
        when(() => mockAuthResponse.user).thenReturn(mockUser);

        when(() => mockGoTrueClient.signUp(
          email: email,
          password: password,
          data: any(named: 'data'),
        )).thenAnswer((_) async => mockAuthResponse);

        await authRepository.signUp(
          email: email,
          password: password,
          username: username,
          phone: phone,
        );

        verify(() => mockGoTrueClient.signUp(
          email: email,
          password: password,
          data: {'username': username, 'phone': phone},
        )).called(1);

        verify(() => mockSupabaseQueryBuilder.insert({
          'id': userId,
          'username': username,
          'phone': phone,
          'email': email,
          'created_at': any(named: 'created_at'),
          'updated_at': any(named: 'updated_at'),
        })).called(1);
      });
    });

    group('signIn', () {
      test('calls signInWithPassword on supabase auth', () async {
        final mockAuthResponse = MockAuthResponse();
        when(() => mockGoTrueClient.signInWithPassword(
          email: email,
          password: password,
        )).thenAnswer((_) async => mockAuthResponse);

        final response = await authRepository.signIn(email: email, password: password);

        expect(response, mockAuthResponse);
        verify(() => mockGoTrueClient.signInWithPassword(
          email: email,
          password: password,
        )).called(1);
      });
    });

    group('signOut', () {
      test('calls signOut on supabase auth', () async {
        when(() => mockGoTrueClient.signOut()).thenAnswer((_) async {});

        await authRepository.signOut();

        verify(() => mockGoTrueClient.signOut()).called(1);
      });
    });
  });
}
