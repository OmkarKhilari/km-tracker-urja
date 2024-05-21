import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:km_tracker/screens/form_page.dart';
import 'package:km_tracker/screens/edit_page.dart';
import 'package:km_tracker/widgets/loading_screen.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);  // Loading state

  void _loginWithGoogle(BuildContext context) async {
    _isLoading.value = true;  // Show loader
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null && user.email!.endsWith('@gmail.com')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Welcome: ${user.displayName}')),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditPage()),
          );
        } else {
          await _auth.signOut();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Access Denied'),
              content: Text('Please use your company email to log in.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign in failed. Please try again.')),
      );
    } finally {
      _isLoading.value = false;  // Hide loader
    }
  }

  void _goToFormPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FormPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoading,
      builder: (context, isLoading, child) {
        return LoadingScreen(
          isLoading: isLoading,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Welcome to Company',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: () => _loginWithGoogle(context),
                      child: Text('Login with Google (HR)'),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                        onPrimary: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        textStyle: TextStyle(fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _goToFormPage(context),
                      child: Text('Continue as Employee'),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                        onPrimary: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        textStyle: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
