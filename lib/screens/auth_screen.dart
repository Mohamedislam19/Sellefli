import 'package:flutter/material.dart';
import 'package:sellefli/screens/login_form.dart';
import 'package:sellefli/screens/signup_form.dart';
import 'package:sellefli/screens/reset_password_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  int currentView = 0; // 0 = Login, 1 = SignUp, 2 = ResetPassword

  void showLogin() {
    setState(() => currentView = 0);
  }

  void showSignUp() {
    setState(() => currentView = 1);
  }

  void showResetPassword() {
    setState(() => currentView = 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: currentView == 0
                ? LoginForm(
                    onToggleSignUp: showSignUp,
                    onForgotPassword: showResetPassword,
                  )
                : currentView == 1
                ? SignUpForm(onToggle: showLogin)
                : ResetPasswordForm(onToggle: showLogin),
          ),
        ),
      ),
    );
  }
}
