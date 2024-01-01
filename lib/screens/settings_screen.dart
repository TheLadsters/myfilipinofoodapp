import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String userEmail = "";
  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    setState(() {
      if (currentUser != null) userEmail = currentUser!.email!;
    });
  }

  void logout(context) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null && !currentUser.isAnonymous) {
      try {
        await GoogleSignIn().disconnect();
        await FirebaseAuth.instance.signOut();
      } catch (e) {
        print(e);
      }

      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                Text(
                  'Current Email: $userEmail',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      logout(context);
                    },
                    icon: const Icon(
                      Icons.logout,
                    ),
                    label: const Text('Logout'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
