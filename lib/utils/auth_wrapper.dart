// ==================== FILE 5: lib/utils/auth_wrapper.dart (UPDATED) ====================
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/auth/login_screen.dart';
import '../main_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading screen while checking authentication state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // Show main screen with bottom navigation if user is authenticated
        if (snapshot.hasData) {
          return const MainScreen();
        }
        
        // Show login screen if user is not authenticated
        return const LoginScreen();
      },
    );
  }
}