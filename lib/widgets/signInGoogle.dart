import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class SignInGoogleGroup extends StatelessWidget {
  const SignInGoogleGroup({super.key, required this.signInWithGoogle});

  final Function signInWithGoogle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Column(
        children: [
          const Text(
            'OR',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SignInButton(
            Buttons.Google,
            onPressed: () {
              signInWithGoogle();
            },
          )
        ],
      ),
    );
  }
}
