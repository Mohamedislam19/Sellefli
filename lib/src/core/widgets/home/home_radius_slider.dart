import 'package:flutter/material.dart';
import 'package:sellefli/l10n/app_localizations.dart';
import 'package:sellefli/src/core/theme/app_theme.dart';

class HomeRadiusSlider extends StatefulWidget {
  final double initialRadius;
  final ValueChanged<double> onChanged;

  const HomeRadiusSlider({
    super.key,
    required this.initialRadius,
    required this.onChanged,
  });

  @override
  State<HomeRadiusSlider> createState() => _HomeRadiusSliderState();
}

class _HomeRadiusSliderState extends State<HomeRadiusSlider> {
  late double _radius;

  @override
  void initState() {
    super.initState();
    _radius = widget.initialRadius;
  }

  @override
  void didUpdateWidget(HomeRadiusSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialRadius != oldWidget.initialRadius) {
      _radius = widget.initialRadius;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${l10n.homeRadiusLabel}:',
                style: AppTextStyles.body.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
              Text(
                l10n.distanceKm(_radius.toStringAsFixed(0)),
                style: AppTextStyles.body.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.primary.withAlpha(
                ((0.2) * 255).toInt(),
              ),
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withAlpha(((0.2) * 255).toInt()),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: _radius,
              min: 1,
              max: 50,
              onChanged: (value) {
                setState(() => _radius = value);
                widget.onChanged(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}


