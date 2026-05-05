import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/auth/screens/splash_screen.dart'; // Ensure this path is correct

void main() async {
  // 1. Mandatory for async initialization
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase using your generated options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartShop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      // The app starts here. SplashScreen will eventually navigate to AuthGate.
      home: const SplashScreen(),
    );
  }
}
