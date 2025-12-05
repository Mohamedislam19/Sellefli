import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sellefli/src/core/theme/app_theme.dart';
import 'package:sellefli/src/data/repositories/auth_repository.dart';
import 'package:sellefli/src/data/repositories/rating_repository.dart';

class RatingPageArguments {
  final String bookingId;
  final String targetUserId;

  RatingPageArguments({required this.bookingId, required this.targetUserId});
}

class RatingWidget extends StatefulWidget {
  final VoidCallback? onCancel;
  final Function(int rating)? onSubmit;

  const RatingWidget({super.key, this.onCancel, this.onSubmit});

  @override
  State<RatingWidget> createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget>
    with SingleTickerProviderStateMixin {
  int _selectedRating = 0;
  int _hoveredRating = 0;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a rating')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final args =
          ModalRoute.of(context)!.settings.arguments as RatingPageArguments;
      final authRepo = context.read<AuthRepository>();
      final ratingRepo = context.read<RatingRepository>();
      final currentUser = authRepo.currentUser;

      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      await ratingRepo.createRating(
        bookingId: args.bookingId,
        raterUserId: currentUser.id,
        targetUserId: args.targetUserId,
        stars: _selectedRating,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rating submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().contains('already rated')
            ? 'You have already rated this booking'
            : 'Error submitting rating: $e';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
        // If already rated, still navigate away
        if (e.toString().contains('already rated')) {
          Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getRatingText() {
    switch (_hoveredRating != 0 ? _hoveredRating : _selectedRating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return 'How many stars would you give?';
    }
  }

  Color _getRatingColor() {
    int rating = _hoveredRating != 0 ? _hoveredRating : _selectedRating;
    switch (rating) {
      case 1:
        return AppColors.danger;
      case 2:
        return Colors.orange;
      case 3:
        return AppColors.accent;
      case 4:
        return Colors.lightGreen;
      case 5:
        return AppColors.success;
      default:
        return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: AppColors.primaryGradient),
      child: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Card(
                color: AppColors.surface,
                elevation: 12,
                shadowColor: AppColors.primaryDark.withAlpha(
                  ((0.2) * 255).toInt(),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: AppColors.border.withAlpha(((0.5) * 255).toInt()),
                    width: 1,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(40.0),
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Icon
                      Hero(
                        tag: 'rating_icon',
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryDark,
                                AppColors.primary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withAlpha(
                                  ((0.3) * 255).toInt(),
                                ),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.star_rounded,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Title
                      Text(
                        'Rate Your Experience',
                        style: AppTextStyles.title.copyWith(
                          color: AppColors.primaryDark,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),

                      // Subtitle with dynamic text
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          _getRatingText(),
                          key: ValueKey<String>(_getRatingText()),
                          style: AppTextStyles.subtitle.copyWith(
                            color: _getRatingColor(),
                            fontSize: 16,
                            height: 1.5,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Star Rating
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            final starNumber = index + 1;
                            final isSelected = starNumber <= _selectedRating;
                            final isHovered = starNumber <= _hoveredRating;
                            final isActive = isHovered || isSelected;

                            return MouseRegion(
                              onEnter: (_) =>
                                  setState(() => _hoveredRating = starNumber),
                              onExit: (_) => setState(() => _hoveredRating = 0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedRating = starNumber;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOut,
                                  padding: const EdgeInsets.all(6),
                                  child: Icon(
                                    isActive
                                        ? Icons.star_rounded
                                        : Icons.star_outline_rounded,
                                    size: 44,
                                    color: isActive
                                        ? _getRatingColor()
                                        : AppColors.muted.withAlpha(
                                            ((0.3) * 255).toInt(),
                                          ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Buttons
                      Row(
                        children: [
                          // Cancel Button
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                side: BorderSide(
                                  color: AppColors.border,
                                  width: 1.5,
                                ),
                                foregroundColor: AppColors.muted,
                              ),
                              child: Text(
                                'Cancel',
                                style: AppTextStyles.subtitle.copyWith(
                                  color: AppColors.muted,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Submit Button
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSubmit,
                              style:
                                  ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    disabledBackgroundColor: AppColors.primary
                                        .withAlpha(((0.6) * 255).toInt()),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 0,
                                    shadowColor: AppColors.primary.withAlpha(
                                      ((0.4) * 255).toInt(),
                                    ),
                                  ).copyWith(
                                    elevation:
                                        WidgetStateProperty.resolveWith<double>(
                                          (states) {
                                            if (states.contains(
                                              WidgetState.pressed,
                                            )) {
                                              return 0;
                                            }
                                            if (states.contains(
                                              WidgetState.hovered,
                                            )) {
                                              return 4;
                                            }
                                            return 2;
                                          },
                                        ),
                                  ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      'Submit Rating',
                                      style: AppTextStyles.subtitle.copyWith(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Example usage screen
class RatingScreen extends StatelessWidget {
  const RatingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withAlpha(((0.1) * 255).toInt()),
              AppColors.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: RatingWidget(onCancel: () {}),
            ),
          ),
        ),
      ),
    );
  }
}
