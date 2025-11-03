import 'package:flutter/material.dart';
import 'package:sellefli/src/core/theme/app_theme.dart';

class LoginForm extends StatefulWidget {
  final VoidCallback onToggleSignUp;
  final VoidCallback onForgotPassword;

  const LoginForm({
    super.key,
    required this.onToggleSignUp,
    required this.onForgotPassword,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;
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
    _phoneController.dispose();
    _passwordController.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _login() {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.pushNamed(context, '/home');
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
                    // Icon with animated gradient
                    Hero(
                      tag: 'auth_icon',
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primaryDark, AppColors.primary],
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
                          Icons.lock_outline,
                          size: 44,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Title with better typography
                    Text(
                      'Hello again!',
                      style: AppTextStyles.title.copyWith(
                        color: AppColors.primaryDark,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Please log in to continue',
                      style: AppTextStyles.subtitle.copyWith(
                        color: AppColors.muted,
                        fontSize: 16,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Phone Field with improved styling
                    TextFormField(
                      controller: _phoneController,
                      focusNode: _phoneFocusNode,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        _passwordFocusNode.requestFocus();
                      },
                      style: AppTextStyles.body.copyWith(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: 'Phone number',
                        hintText: '06 12 34 56 78',
                        hintStyle: TextStyle(
                          color: AppColors.muted.withAlpha(
                            ((0.5) * 255).toInt(),
                          ),
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(
                              ((0.1) * 255).toInt(),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.phone_outlined,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        filled: true,
                        fillColor: AppColors.primary.withAlpha(
                          ((0.03) * 255).toInt(),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: AppColors.border.withAlpha(
                              ((0.3) * 255).toInt(),
                            ),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: AppColors.danger,
                            width: 1,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: AppColors.danger,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Password Field with improved styling
                    TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
                      style: AppTextStyles.body.copyWith(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(
                              ((0.1) * 255).toInt(),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.lock_outline,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.muted,
                            size: 22,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          splashRadius: 24,
                        ),
                        filled: true,
                        fillColor: AppColors.primary.withAlpha(
                          ((0.03) * 255).toInt(),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: AppColors.border.withAlpha(
                              ((0.3) * 255).toInt(),
                            ),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: AppColors.danger,
                            width: 1,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: AppColors.danger,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Forgot Password with better touch target
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: widget.onForgotPassword,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          minimumSize: const Size(0, 40),
                        ),
                        child: Text(
                          'Forgot your password?',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Login Button with better styling
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
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
                            elevation:
                                MaterialStateProperty.resolveWith<double>((
                                  states,
                                ) {
                                  if (states.contains(MaterialState.pressed)) {
                                    return 0;
                                  }
                                  if (states.contains(MaterialState.hovered)) {
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
                              'Log in',
                              style: AppTextStyles.subtitle.copyWith(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                    ),
                    const SizedBox(height: 28),

                    // Sign Up Link with better spacing and touch target
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account? ',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.muted,
                            fontSize: 15,
                          ),
                        ),
                        InkWell(
                          onTap: widget.onToggleSignUp,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Text(
                              'Register',
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
