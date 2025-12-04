import 'package:flutter/material.dart';
import 'package:sellefli/src/core/utils/validators.dart';
import 'package:sellefli/src/core/widgets/auth/auth_text_field.dart';

class SignUpFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final bool isLoading;

  const SignUpFields({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AuthTextField(
          controller: nameController,
          label: 'Full Name',
          hint: 'Mohammed Ahmed',
          prefixIcon: Icons.person_outline,
          isEnabled: !isLoading,
          validator: Validators.validateFullName,
        ),
        const SizedBox(height: 20),
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
          controller: phoneController,
          label: 'Phone Number',
          hint: '05 12 34 56 78',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          isEnabled: !isLoading,
          validator: Validators.validatePhone,
        ),
        const SizedBox(height: 20),
        AuthTextField(
          controller: passwordController,
          label: 'Password',
          hint: 'Enter your password',
          prefixIcon: Icons.lock_outline,
          isPassword: true,
          isEnabled: !isLoading,
          validator: Validators.validatePassword,
        ),
      ],
    );
  }
}
