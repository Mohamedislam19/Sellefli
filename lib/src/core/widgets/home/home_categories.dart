import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sellefli/src/core/theme/app_theme.dart';
import 'package:sellefli/src/core/constants/categories.dart';
import 'package:sellefli/src/features/home/logic/home_cubit.dart';
import 'package:sellefli/src/features/home/logic/home_state.dart';

class HomeCategories extends StatelessWidget {
  const HomeCategories({super.key});

  static final List<String> _categories = ['All', ...AppCategories.categories];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: BlocBuilder<HomeCubit, HomeState>(
        buildWhen: (previous, current) =>
            previous.selectedCategories != current.selectedCategories,
        builder: (context, state) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = state.selectedCategories.contains(category);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(category),
                  labelStyle: AppTextStyles.body.copyWith(
                    color: isSelected ? Colors.white : AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.primary,
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.primary.withAlpha(((0.5) * 255).toInt()),
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onSelected: (selected) {
                    context.read<HomeCubit>().selectCategory(category);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
