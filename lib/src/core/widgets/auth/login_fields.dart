import 'package:flutter/material.dart';
import 'package:sellefli/src/core/utils/validators.dart';
import 'package:sellefli/src/core/widgets/auth/auth_text_field.dart';

class LoginFields extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onLogin;

  const LoginFields({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AuthTextField(
          controller: emailController,
          label: 'Email',
          hint: 'example@email.com',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          isEnabled: !isLoading,
          validator: Validators.validateEmail,
        ),
        const SizedBox(height: 20),
        AuthTextField(
          controller: passwordController,
          label: 'Password',
          hint: 'Enter your password',
          prefixIcon: Icons.lock_outline,
          isPassword: true,
          isEnabled: !isLoading,
          validator: Validators.validateLoginPassword,
        ),
      ],
    );
  }
}
