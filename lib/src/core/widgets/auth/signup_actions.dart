import 'package:flutter/material.dart';
import 'package:sellefli/l10n/app_localizations.dart';
import 'package:sellefli/src/core/theme/app_theme.dart';

class SignUpActions extends StatelessWidget {
  final VoidCallback onSignUp;
  final VoidCallback onToggleLogin;
  final bool isLoading;

  const SignUpActions({
    super.key,
    required this.onSignUp,
    required this.onToggleLogin,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        // Sign Up Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : onSignUp,
            style:
                ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withAlpha(
                    ((0.6) * 255).toInt(),
                  ),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                  shadowColor: AppColors.primary.withAlpha(
                    ((0.4) * 255).toInt(),
                  ),
                ).copyWith(
                  elevation: WidgetStateProperty.resolveWith<double>((states) {
                    if (states.contains(WidgetState.pressed)) {
                      return 0;
                    }
                    if (states.contains(WidgetState.hovered)) {
                      return 4;
                    }
                    return 2;
                  }),
                ),
            child: isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    l10n.authRegister,
                    style: AppTextStyles.subtitle.copyWith(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 28),

        // Login Link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${l10n.authAlreadyAccount} ',
              style: AppTextStyles.body.copyWith(
                color: AppColors.muted,
                fontSize: 15,
              ),
            ),
            InkWell(
              onTap: onToggleLogin,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  l10n.authLoginButton,
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}


