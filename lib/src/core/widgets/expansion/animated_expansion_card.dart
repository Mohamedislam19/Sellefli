// lib/src/core/widgets/expansion/animated_expansion_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart'; // imports primaryBlue

class AnimatedExpansionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final InlineSpan? descriptionSpan;
  final Widget? descriptionWidget;
  final double scale;

  const AnimatedExpansionCard({
    Key? key,
    required this.icon,
    required this.title,
    this.descriptionSpan,
    this.descriptionWidget,
    this.scale = 1.0,
  }) : super(key: key);

  @override
  State<AnimatedExpansionCard> createState() => _AnimatedExpansionCardState();
}

class _AnimatedExpansionCardState extends State<AnimatedExpansionCard>
    with SingleTickerProviderStateMixin {
  bool expanded = false;
  late AnimationController _controller;
  late Animation<double> _iconRotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _iconRotation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );
  }

  void toggleExpand() {
    setState(() {
      expanded = !expanded;
      if (expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final descriptionContent =
        widget.descriptionWidget ??
        (widget.descriptionSpan != null
            ? RichText(text: widget.descriptionSpan!)
            : Container());

    return AnimatedContainer(
      margin: EdgeInsets.symmetric(vertical: 8 * widget.scale),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18 * widget.scale),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withAlpha(((0.07) * 255).toInt()),
            blurRadius: 14 * widget.scale,
            offset: Offset(0, 6 * widget.scale),
          ),
        ],
        border: Border.all(
          color: AppColors.primaryBlue.withAlpha(
            ((expanded ? 0.25 : 0.11) * 255).toInt(),
          ),
          width: expanded ? 2 * widget.scale : 1 * widget.scale,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18 * widget.scale),
          splashColor: AppColors.primaryBlue.withAlpha(((0.11) * 255).toInt()),
          onTap: toggleExpand,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 4 * widget.scale,
              horizontal: 12 * widget.scale,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primaryBlue.withAlpha(
                        ((0.1) * 255).toInt(),
                      ),
                      foregroundColor: AppColors.primaryBlue,
                      radius: 22 * widget.scale,
                      child: Icon(widget.icon, size: 26 * widget.scale),
                    ),
                    SizedBox(width: 14 * widget.scale),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: GoogleFonts.outfit(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w700,
                          fontSize: 17 * widget.scale,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    RotationTransition(
                      turns: _iconRotation,
                      child: Icon(
                        Icons.expand_more_rounded,
                        color: AppColors.primaryBlue,
                        size: 28 * widget.scale,
                      ),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 360),
                  crossFadeState: expanded
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Padding(
                    padding: EdgeInsets.only(
                      top: 10 * widget.scale,
                      left: 8 * widget.scale,
                      right: 8 * widget.scale,
                      bottom: 14 * widget.scale,
                    ),
                    child: descriptionContent,
                  ),
                  secondChild: Container(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// SubExpansionCard (FAQ item)
class SubExpansionCard extends StatefulWidget {
  final String title;
  final String description;
  final double scale;

  const SubExpansionCard({
    Key? key,
    required this.title,
    required this.description,
    this.scale = 1.0,
  }) : super(key: key);

  @override
  State<SubExpansionCard> createState() => _SubExpansionCardState();
}

class _SubExpansionCardState extends State<SubExpansionCard>
    with SingleTickerProviderStateMixin {
  bool expanded = false;
  late AnimationController _controller;
  late Animation<double> _iconRotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _iconRotation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );
  }

  void toggleExpand() {
    setState(() {
      expanded = !expanded;
      if (expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: toggleExpand,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8 * widget.scale),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: GoogleFonts.outfit(
                      fontSize: 15 * widget.scale,
                      color: const Color.fromARGB(255, 0, 58, 84),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                RotationTransition(
                  turns: _iconRotation,
                  child: Icon(
                    Icons.expand_more_rounded,
                    size: 20 * widget.scale,
                    color: Colors.blueGrey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 280),
          crossFadeState: expanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Padding(
            padding: EdgeInsets.only(
              left: 12 * widget.scale,
              bottom: 12 * widget.scale,
            ),
            child: Text(
              widget.description,
              style: GoogleFonts.outfit(
                fontSize: 14 * widget.scale,
                color: Colors.blueGrey.shade800,
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          secondChild: Container(),
        ),
      ],
    );
  }
}
