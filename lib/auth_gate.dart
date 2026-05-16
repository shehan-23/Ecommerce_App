import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/navigation/main_wrapper.dart'; 

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. While Firebase is checking the auth state, show a dark loader
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0F0F14),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFFF4D6D)),
            ),
          );
        }

        // 2. If the user is already logged in, take them to the app
        if (snapshot.hasData && snapshot.data != null) {
          return const MainNavigationWrapper();
        } 
        
        // 3. If there is no user session, show the Login/Register page
        return const LoginScreen();
      },
    );
  }
}