import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// Remove the main.dart import as it's not needed here
import 'features/auth/screens/login_screen.dart';
import 'features/home/home_screen.dart'; // Import the screen you just checked

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ✅ FIX: Return HomeScreen instead of MyApp
          if (snapshot.hasData) {
            return HomeScreen();
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}
