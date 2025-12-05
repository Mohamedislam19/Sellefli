import 'package:flutter/material.dart';
import 'package:sellefli/src/core/theme/app_theme.dart';
import 'package:sellefli/src/core/utils/validators.dart';
import 'package:sellefli/src/core/widgets/auth/auth_text_field.dart';
import 'package:sellefli/src/core/widgets/auth/reset_password_header.dart';

class ResetPasswordForm extends StatefulWidget {
  final VoidCallback onToggle;

  const ResetPasswordForm({super.key, required this.onToggle});

  @override
  State<ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<ResetPasswordForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _resetPassword() {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isLoading = false);
          // In a real app, you would call the auth cubit here
          Navigator.pushNamed(context, '/auth');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Card(
            color: AppColors.surface,
            elevation: 8,
            shadowColor: AppColors.primaryDark.withAlpha(((0.2) * 255).toInt()),
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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const ResetPasswordHeader(),
                    const SizedBox(height: 40),
                    AuthTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'example@email.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _resetPassword,
                      style:
                          ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor: AppColors.primary
                                .withAlpha(((0.6) * 255).toInt()),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                            shadowColor: AppColors.primary.withAlpha(
                              ((0.4) * 255).toInt(),
                            ),
                          ).copyWith(
                            elevation: WidgetStateProperty.resolveWith<double>((
                              states,
                            ) {
                              if (states.contains(WidgetState.pressed)) {
                                return 0;
                              }
                              if (states.contains(WidgetState.hovered)) {
                                return 4;
                              }
                              return 2;
                            }),
                          ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'Send Reset Link',
                              style: AppTextStyles.subtitle.copyWith(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: AppColors.border.withAlpha(
                              ((0.5) * 255).toInt(),
                            ),
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.muted,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: AppColors.border.withAlpha(
                              ((0.5) * 255).toInt(),
                            ),
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Remember your password? ',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.muted,
                            fontSize: 15,
                          ),
                        ),
                        InkWell(
                          onTap: widget.onToggle,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Text(
                              'Log in',
                              style: AppTextStyles.subtitle.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
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
    );
  }
}
