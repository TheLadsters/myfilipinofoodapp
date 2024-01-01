import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({super.key, required this.loginWithEmailPassword});

  final Function loginWithEmailPassword;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: const ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(
          Colors.yellow,
        ),
        foregroundColor: MaterialStatePropertyAll(
          Colors.black,
        ),
        minimumSize: MaterialStatePropertyAll(
          Size(300, 30),
        ),
      ),
      onPressed: () {
        loginWithEmailPassword();
      },
      icon: const Icon(
        Icons.login,
      ),
      label: const Text('Login'),
    );
  }
}
