import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:myfilipinofoodapp/widgets/app_header.dart';
import 'package:myfilipinofoodapp/widgets/login_button.dart';
import 'package:myfilipinofoodapp/widgets/register_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myfilipinofoodapp/widgets/signInGoogle.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool isLoading = false;
  bool isPasswordHidden = true;
  bool isRegistering = false;
  String textError = "";
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  void _updateVisibility() {
    setState(() {
      isPasswordHidden = !isPasswordHidden;
    });
  }

  void _updateRegister() {
    setState(() {
      emailTextEditingController.text = "";
      passwordTextEditingController.text = "";
      isRegistering = !isRegistering;
    });
  }

  loginWithEmailPassword() async {
    setState(() {
      isLoading = true;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailTextEditingController.text,
        password: passwordTextEditingController.text,
      );

      // Get the currently signed-in user
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && !currentUser.isAnonymous) {
        print(currentUser);
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/homepage');
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "invalid-email":
          print("You have entered an invalid email.");
          break;
        case "user-disabled":
          print("The current user is disabled.");
          break;
        case "user-not-found":
          print("The current provided credentials could not find a user.");
          break;
        case "wrong-password":
          print("You have entered an invalid password.");
          break;
        // See the API reference for the full list of error codes.
        default:
          print("Unknown error.");
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  void signInWithGoogle() async {
    setState(() {
      isLoading = true;
    });
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/homepage');
      // Once signed in, return the UserCredential
      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print(e);
    }
    setState(() {
      isLoading = false;
    });
  }

  registerWithEmailPassword() async {
    setState(() {
      isLoading = true;
    });
    try {
      // Create a new user with email and password
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextEditingController.text,
        password: passwordTextEditingController.text,
      );

      // Get the currently signed-in user
      User? currentUser = FirebaseAuth.instance.currentUser;

      // Disconnect the current Google Sign-In account
      if (GoogleSignIn().currentUser != null) {
        try {
          await GoogleSignIn().signOut();
          await GoogleSignIn().disconnect();
        } catch (e) {
          print('Failed to disconnect Google Sign-In: $e');
          // Handle the error or continue execution based on your requirements
        }
      }

      // Get the Google Sign-In provider
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final googleCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Link the Email/Password provider and Google Account
      if (currentUser != null && !currentUser.isAnonymous) {
        await currentUser.linkWithCredential(googleCredential);
      }

      // Add user data to Firestore
      final db = FirebaseFirestore.instance;
      final user = <String, dynamic>{
        "email": emailTextEditingController.text,
      };

      await db.collection("users").add(user);

      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/homepage');
    } catch (e) {
      print(e);
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600,
      width: 300,
      child: Column(
        children: [
          const AppHeader(),
          const SizedBox(height: 12),
          Text(
            isRegistering ? 'REGISTER' : 'LOGIN',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          TextField(
            controller: emailTextEditingController,
            decoration: const InputDecoration(
              filled: true,
              floatingLabelBehavior: FloatingLabelBehavior.never,
              label: Text('Email'),
              fillColor: Colors.white,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          TextField(
            controller: passwordTextEditingController,
            obscureText: isPasswordHidden,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                onPressed: _updateVisibility,
                icon: Icon(
                  isPasswordHidden ? Icons.visibility : Icons.visibility_off,
                ),
              ),
              filled: true,
              floatingLabelBehavior: FloatingLabelBehavior.never,
              label: const Text('Password'),
              fillColor: Colors.white,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          isRegistering
              ? isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : RegisterButton(
                      registerWithEmailPassword: registerWithEmailPassword,
                    )
              : isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : LoginButton(
                      loginWithEmailPassword: loginWithEmailPassword,
                    ),
          isLoading
              ? const Text("")
              : TextButton(
                  onPressed: _updateRegister,
                  style: const ButtonStyle(
                    foregroundColor: MaterialStatePropertyAll(
                      Colors.white,
                    ),
                  ),
                  child: Text(
                    isRegistering
                        ? "Do you want to login? Login here."
                        : "Don't have an account? Register here.",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
          isRegistering
              ? const SizedBox(height: 1)
              : isLoading
                  ? const Text("")
                  : SignInGoogleGroup(
                      signInWithGoogle: signInWithGoogle,
                    ),
        ],
      ),
    );
  }
}
