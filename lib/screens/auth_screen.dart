import 'package:flutter/material.dart';
import 'package:sellefli/screens/login_form.dart';
import 'package:sellefli/screens/signup_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;

  void toggleView() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: isLogin
                ? LoginForm(onToggle: toggleView)
                : SignUpForm(onToggle: toggleView),
          ),
        ),
      ),
    );
  }
}
