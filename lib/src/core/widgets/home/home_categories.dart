import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sellefli/l10n/app_localizations.dart';
import 'package:sellefli/src/core/theme/app_theme.dart';
import 'package:sellefli/src/core/constants/categories.dart';
import 'package:sellefli/src/features/home/logic/home_cubit.dart';
import 'package:sellefli/src/features/home/logic/home_state.dart';

class HomeCategories extends StatelessWidget {
  const HomeCategories({super.key});

  static final List<String> _categories = ['All', ...AppCategories.categories];

  String _labelFor(BuildContext context, String category) {
    final l10n = AppLocalizations.of(context);
    switch (category) {
      case 'All':
        return l10n.categoryAll;
      case 'Electronics & Tech':
        return l10n.categoryElectronicsTech;
      case 'Home & Appliances':
        return l10n.categoryHomeAppliances;
      case 'Furniture & Décor':
        return l10n.categoryFurnitureDecor;
      case 'Tools & Equipment':
        return l10n.categoryToolsEquipment;
      case 'Vehicles & Mobility':
        return l10n.categoryVehiclesMobility;
      case 'Sports & Outdoors':
        return l10n.categorySportsOutdoors;
      case 'Books & Study':
        return l10n.categoryBooksStudy;
      case 'Fashion & Accessories':
        return l10n.categoryFashionAccessories;
      case 'Events & Celebrations':
        return l10n.categoryEventsCelebrations;
      case 'Baby & Kids':
        return l10n.categoryBabyKids;
      case 'Health & Personal Care':
        return l10n.categoryHealthPersonal;
      case 'Musical Instruments':
        return l10n.categoryMusicalInstruments;
      case 'Hobbies & Crafts':
        return l10n.categoryHobbiesCrafts;
      case 'Pet Supplies':
        return l10n.categoryPetSupplies;
      case 'Other Items':
      default:
        return l10n.categoryOther;
    }
  }

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
                  label: Text(_labelFor(context, category)),
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


