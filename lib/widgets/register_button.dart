import 'package:flutter/material.dart';

class RegisterButton extends StatelessWidget {
  const RegisterButton({super.key, required this.registerWithEmailPassword});

  final Function registerWithEmailPassword;

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
        registerWithEmailPassword();
      },
      icon: const Icon(
        Icons.person,
      ),
      label: const Text('Register'),
    );
  }
}
