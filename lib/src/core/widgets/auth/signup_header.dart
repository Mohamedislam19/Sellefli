import 'package:flutter/material.dart';
import 'package:sellefli/src/core/theme/app_theme.dart';

class SignUpHeader extends StatelessWidget {
  const SignUpHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Icon with animated gradient
        Hero(
          tag: 'auth_icon',
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryDark,
                  AppColors.primary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(
                    ((0.3) * 255).toInt(),
                  ),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_add_outlined,
              size: 44,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Title with better typography
        Text(
          'Create an account',
          style: AppTextStyles.title.copyWith(
            color: AppColors.primaryDark,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'Join us today',
          style: AppTextStyles.subtitle.copyWith(
            color: AppColors.muted,
            fontSize: 16,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
