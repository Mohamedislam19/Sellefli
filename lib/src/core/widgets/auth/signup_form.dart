import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sellefli/src/core/theme/app_theme.dart';
import 'package:sellefli/src/features/auth/logic/auth_cubit.dart';
import 'package:sellefli/src/features/auth/logic/auth_state.dart';
import 'package:sellefli/src/core/widgets/auth/signup_header.dart';
import 'package:sellefli/src/core/widgets/auth/signup_fields.dart';
import 'package:sellefli/src/core/widgets/auth/signup_actions.dart';

class SignUpForm extends StatefulWidget {
  final VoidCallback onToggle;

  const SignUpForm({super.key, required this.onToggle});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _signUp() {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      // Use email for authentication, keep phone for profile
      context.read<AuthCubit>().signup(
        email: _emailController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
        username: _nameController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          setState(() => _isLoading = true);
        } else {
          setState(() => _isLoading = false);
        }
      },
      builder: (context, state) {
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
                          const SignUpHeader(),
                          const SizedBox(height: 40),
                          SignUpFields(
                            nameController: _nameController,
                            emailController: _emailController,
                            phoneController: _phoneController,
                            passwordController: _passwordController,
                            isLoading: _isLoading,
                          ),
                          const SizedBox(height: 32),
                          SignUpActions(
                            onSignUp: _signUp,
                            onToggleLogin: widget.onToggle,
                            isLoading: _isLoading,
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


