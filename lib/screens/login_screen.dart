import 'package:flutter/material.dart';
import 'package:myfilipinofoodapp/widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.brown,
      body: Center(
        child: LoginForm(),
      ),
    );
  }
}
