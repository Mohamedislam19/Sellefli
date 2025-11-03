// lib/src/core/widgets/buttons/advanced_button.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AdvancedButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool fullWidth;
  final Gradient? gradient;
  final Color? foregroundColor;
  final double borderRadius;
  final double elevation;

  const AdvancedButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.fullWidth = true,
    this.gradient,
    this.foregroundColor,
    this.borderRadius = 12,
    this.elevation = 6,
  }) : super(key: key);

  @override
  State<AdvancedButton> createState() => _AdvancedButtonState();
}

class _AdvancedButtonState extends State<AdvancedButton>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _ctrl.addListener(() {
      setState(() => _scale = 1 - (_ctrl.value * 0.06));
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _ctrl.forward();
  void _onTapUp(_) => _ctrl.reverse();
  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    final gradient =
        widget.gradient ??
        const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

    final fg = widget.foregroundColor ?? Colors.white;

    return GestureDetector(
      onTapDown: widget.onPressed != null ? _onTapDown : null,
      onTapUp: widget.onPressed != null ? _onTapUp : null,
      onTapCancel: widget.onPressed != null ? _onTapCancel : null,
      onTap: widget.loading ? null : widget.onPressed,
      child: Transform.scale(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: widget.fullWidth ? double.infinity : null,
          decoration: BoxDecoration(
            gradient: widget.onPressed == null ? null : gradient,
            color: widget.onPressed == null ? Colors.grey.shade300 : null,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: widget.onPressed == null
                ? []
                : [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(
                        ((0.18) * 255).toInt(),
                      ),
                      offset: Offset(0, widget.elevation / 2),
                      blurRadius: widget.elevation,
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Center(
              child: widget.loading
                  ? SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(fg),
                      ),
                    )
                  : Text(
                      widget.label,
                      style: TextStyle(
                        color: fg,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
