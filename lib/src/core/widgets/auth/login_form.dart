import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sellefli/src/core/theme/app_theme.dart';
import 'package:sellefli/src/features/auth/logic/auth_cubit.dart';
import 'package:sellefli/src/features/auth/logic/auth_state.dart';
import 'package:sellefli/src/core/widgets/auth/login_header.dart';
import 'package:sellefli/src/core/widgets/auth/login_fields.dart';
import 'package:sellefli/src/core/widgets/auth/login_actions.dart';

class LoginForm extends StatefulWidget {
  final VoidCallback onToggleSignUp;
  final VoidCallback onForgotPassword;

  const LoginForm({
    super.key,
    required this.onToggleSignUp,
    required this.onForgotPassword,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _login() {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      // Use email directly for authentication
      context.read<AuthCubit>().login(
        _emailController.text,
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        // Handle other side effects if necessary
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Card(
                  color: AppColors.surface,
                  elevation: 8,
                  shadowColor: AppColors.primaryDark.withAlpha(
                    ((0.2) * 255).toInt(),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(
                      color: AppColors.border.withAlpha(((0.5) * 255).toInt()),
                      width: 1,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(40.0),
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const LoginHeader(),
                          const SizedBox(height: 40),
                          LoginFields(
                            emailController: _emailController,
                            passwordController: _passwordController,
                            isLoading: isLoading,
                            onLogin: _login,
                          ),
                          const SizedBox(height: 16),
                          LoginActions(
                            onForgotPassword: widget.onForgotPassword,
                            onLogin: _login,
                            onToggleSignUp: widget.onToggleSignUp,
                            isLoading: isLoading,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
