import 'package:flutter/material.dart';
import 'package:sellefli/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        AuthTextField(
          controller: nameController,
          label: l10n.authFullNameLabel,
          hint: l10n.authFullNameHint,
          prefixIcon: Icons.person_outline,
          isEnabled: !isLoading,
          validator: (value) => Validators.validateFullName(context, value),
        ),
        const SizedBox(height: 20),
        AuthTextField(
          controller: emailController,
          label: l10n.authEmailLabel,
          hint: l10n.authEmailHint,
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          isEnabled: !isLoading,
          validator: (value) => Validators.validateEmail(context, value),
        ),
        const SizedBox(height: 20),
        AuthTextField(
          controller: phoneController,
          label: l10n.authPhoneLabel,
          hint: l10n.authPhoneHint,
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          isEnabled: !isLoading,
          validator: (value) => Validators.validatePhone(context, value),
        ),
        const SizedBox(height: 20),
        AuthTextField(
          controller: passwordController,
          label: l10n.authPasswordLabel,
          hint: l10n.authPasswordHint,
          prefixIcon: Icons.lock_outline,
          isPassword: true,
          isEnabled: !isLoading,
          validator: (value) => Validators.validatePassword(context, value),
        ),
      ],
    );
  }
}


