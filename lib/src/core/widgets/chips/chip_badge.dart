import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

enum ChipType { primary, ghost, muted, danger }

class ChipBadge extends StatelessWidget {
  final String label;
  final ChipType type;
  final bool small;

  const ChipBadge({
    super.key,
    required this.label,
    this.type = ChipType.primary,
    this.small = false,
  });

  Color _bgColor() {
    switch (type) {
      case ChipType.primary:
        return AppColors.primary;
      case ChipType.ghost:
        return Colors.white;
      case ChipType.muted:
        return Colors.white;
      case ChipType.danger:
        return AppColors.danger;
    }
  }

  Color _textColor() {
    if (type == ChipType.primary || type == ChipType.danger) {
      return Colors.white;
    }
    return Colors.black87;
  }

  BoxBorder? _border() {
    if (type == ChipType.ghost || type == ChipType.muted) {
      return Border.all(color: AppColors.border);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final padding = small
        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _bgColor(),
        borderRadius: BorderRadius.circular(20),
        border: _border(),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: small ? 12 : 13,
          fontWeight: FontWeight.w600,
          color: _textColor(),
        ),
      ),
    );
  }
}


