// lib/src/core/widgets/dropdown/animated_dropdown.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sellefli/src/features/item/create_item_page.dart';
import '../../theme/app_theme.dart';

class AnimatedDropdown extends StatefulWidget {
  final List<String> categories;
  final String selected;
  final double scale;
  final ValueChanged<String> onChanged;

  const AnimatedDropdown({
    required this.categories,
    required this.selected,
    required this.scale,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  State<AnimatedDropdown> createState() => _AnimatedDropdownState();
}

class _AnimatedDropdownState extends State<AnimatedDropdown>
    with SingleTickerProviderStateMixin {
  late AnimationController _dropdownAnim;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _dropdownAnim = AnimationController(
      duration: const Duration(milliseconds: 320),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _dropdownAnim.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _dropdownAnim.forward();
      } else {
        _dropdownAnim.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _toggleDropdown,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 190),
            curve: Curves.easeInOut,
            padding: EdgeInsets.symmetric(
              horizontal: 17 * widget.scale,
              vertical: 13 * widget.scale,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13 * widget.scale),
              border: Border.all(
                color: AppColors.primaryBlue.withOpacity(0.4),
                width: 1.1,
              ),
              boxShadow: _expanded
                  ? [
                      BoxShadow(
                        color: AppColors.primaryBlue.withOpacity(0.11),
                        blurRadius: 12 * widget.scale,
                        offset: Offset(0, 4 * widget.scale),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 220),
                    style: GoogleFonts.outfit(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 15.5 * widget.scale,
                    ),
                    child: Text(widget.selected),
                  ),
                ),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 160),
                  turns: _expanded ? 0.5 : 0.0,
                  child: Icon(
                    Icons.expand_more_rounded,
                    color: AppColors.primaryBlue,
                    size: 23 * widget.scale,
                  ),
                ),
              ],
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(12 * widget.scale),
          child: SizeTransition(
            sizeFactor: CurvedAnimation(
              parent: _dropdownAnim,
              curve: Curves.easeOut,
            ),
            axisAlignment: -1,
            child: Container(
              margin: EdgeInsets.only(top: 2 * widget.scale),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: AppColors.primaryBlue.withOpacity(0.22),
                  width: 1,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(13 * widget.scale),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.09),
                    blurRadius: 10 * widget.scale,
                    offset: Offset(0, 5 * widget.scale),
                  ),
                ],
              ),
              child: Column(
                children: widget.categories
                    .map(
                      (cat) => Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            widget.onChanged(cat);
                            _toggleDropdown();
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              vertical: 13 * widget.scale,
                              horizontal: 17 * widget.scale,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  cat == widget.selected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_unchecked,
                                  size: 18 * widget.scale,
                                  color: cat == widget.selected
                                      ? AppColors.primaryBlue
                                      : Colors.grey[400],
                                ),
                                SizedBox(width: 9 * widget.scale),
                                Text(
                                  cat,
                                  style: GoogleFonts.outfit(
                                    color: cat == widget.selected
                                        ? AppColors.primaryBlue
                                        : Colors.black87,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15 * widget.scale,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
