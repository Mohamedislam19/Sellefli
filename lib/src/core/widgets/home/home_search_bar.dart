import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sellefli/l10n/app_localizations.dart';
import 'package:sellefli/src/core/theme/app_theme.dart';
import 'package:sellefli/src/features/home/logic/home_cubit.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(((0.05) * 255).toInt()),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.border.withAlpha(((0.3) * 255).toInt()),
            width: 1,
          ),
        ),
        child: TextField(
          style: AppTextStyles.body.copyWith(fontSize: 16),
          onChanged: (value) =>
              context.read<HomeCubit>().updateSearchQuery(value),
          decoration: InputDecoration(
            hintText: l10n.homeSearchHint,
            hintStyle: TextStyle(
              color: AppColors.muted.withAlpha(((0.6) * 255).toInt()),
            ),
            prefixIcon: Icon(Icons.search, color: AppColors.primary, size: 22),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }
}


