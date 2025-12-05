import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sellefli/src/core/theme/app_theme.dart';
import 'package:sellefli/src/features/home/logic/home_cubit.dart';
import 'package:sellefli/src/features/home/logic/home_state.dart';

class HomeLocationToggle extends StatelessWidget {
  const HomeLocationToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.isLocationEnabled != current.isLocationEnabled,
      builder: (context, state) {
        return Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: state.isLocationEnabled
                  ? AppColors.primary.withAlpha(((0.1) * 255).toInt())
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF2F6CE6).withAlpha(((0.5) * 255).toInt()),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on,
                  size: 18,
                  color: state.isLocationEnabled
                      ? AppColors.primary
                      : AppColors.primaryBlue,
                ),
                const SizedBox(width: 8),
                Text(
                  'Use my location',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14,
                    color: state.isLocationEnabled
                        ? AppColors.primary
                        : AppColors.muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: state.isLocationEnabled,
                  onChanged: (value) {
                    context.read<HomeCubit>().toggleLocation(value);
                  },
                  activeThumbColor: AppColors.primary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
