import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sellefli/src/features/auth/logic/auth_cubit.dart';
import 'package:sellefli/src/features/auth/logic/auth_state.dart';
import 'package:sellefli/src/features/auth/login_form.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late MockAuthCubit mockAuthCubit;

  setUp(() {
    mockAuthCubit = MockAuthCubit();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<AuthCubit>.value(
          value: mockAuthCubit,
          child: LoginForm(
            onToggleSignUp: () {},
            onForgotPassword: () {},
          ),
        ),
      ),
    );
  }

  group('LoginForm', () {
    testWidgets('renders email and password fields', (tester) async {
      when(() => mockAuthCubit.state).thenReturn(AuthInitial());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle(); // Wait for animations

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Log in'), findsOneWidget);
    });

    testWidgets('shows error when fields are empty and login is pressed', (tester) async {
      when(() => mockAuthCubit.state).thenReturn(AuthInitial());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log in'));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('calls login on cubit when valid fields are submitted', (tester) async {
      when(() => mockAuthCubit.state).thenReturn(AuthInitial());
      when(() => mockAuthCubit.login(any(), any())).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      
      await tester.tap(find.text('Log in'));
      await tester.pump(); // Start animation/processing
      
      // Verify login is called
      verify(() => mockAuthCubit.login(any(), any())).called(1);
    });

    testWidgets('shows loading indicator when state is AuthLoading', (tester) async {
      when(() => mockAuthCubit.state).thenReturn(AuthLoading());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Do not pumpAndSettle because animation might be infinite

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
