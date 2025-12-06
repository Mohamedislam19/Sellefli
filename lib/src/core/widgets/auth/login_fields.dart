import 'package:flutter/material.dart';
import 'package:sellefli/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
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
          controller: passwordController,
          label: l10n.authPasswordLabel,
          hint: l10n.authPasswordHint,
          prefixIcon: Icons.lock_outline,
          isPassword: true,
          isEnabled: !isLoading,
          validator: (value) =>
              Validators.validateLoginPassword(context, value),
        ),
      ],
    );
  }
}


