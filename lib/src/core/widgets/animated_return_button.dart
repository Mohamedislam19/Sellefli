// lib/src/core/widgets/animated_return_button.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // optional, kept if you later add text
import 'package:sellefli/src/features/settings/settings_page.dart';
import 'package:sellefli/src/core/theme/app_theme.dart';

class AnimatedReturnButton extends StatefulWidget {
  const AnimatedReturnButton({Key? key}) : super(key: key);

  @override
  State<AnimatedReturnButton> createState() => _AnimatedReturnButtonState();
}

class _AnimatedReturnButtonState extends State<AnimatedReturnButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 260),
      vsync: this,
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        Navigator.of(context).maybePop();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryBlue.withOpacity(0),
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.primaryBlue,
            size: 26,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
