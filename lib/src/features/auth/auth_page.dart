import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sellefli/src/core/theme/app_theme.dart';
import 'package:sellefli/src/core/widgets/auth/login_form.dart';
import 'package:sellefli/src/features/auth/logic/auth_cubit.dart';
import 'package:sellefli/src/features/auth/logic/auth_state.dart';
import 'package:sellefli/src/core/widgets/auth/signup_form.dart';
import 'package:sellefli/src/core/widgets/auth/reset_password_form.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  int currentView = 0; // 0 = Login, 1 = SignUp, 2 = ResetPassword

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Read route arguments to set initial view
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('initialView')) {
      setState(() {
        currentView = args['initialView'] as int;
      });
    }
  }

  void showLogin() {
    setState(() => currentView = 0);
  }

  void showSignUp() {
    setState(() => currentView = 1);
  }

  void showResetPassword() {
    setState(() => currentView = 2);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Show success message based on which form was used
          String message = currentView == 1
              ? 'Account created successfully! Welcome to Sellefli.'
              : 'Welcome back! Login successful.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
              duration: const Duration(milliseconds: 1500),
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Navigate to home on successful authentication
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/home');
            }
          });
        } else if (state is AuthError) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: currentView == 0
                    ? LoginForm(
                        onToggleSignUp: showSignUp,
                        onForgotPassword: showResetPassword,
                      )
                    : currentView == 1
                    ? SignUpForm(onToggle: showLogin)
                    : ResetPasswordForm(onToggle: showLogin),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
