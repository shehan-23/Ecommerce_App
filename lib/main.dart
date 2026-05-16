import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
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
      title: 'FitKarma',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(
          0xFF0F0F14,
        ), // Near-black background
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF4D6D), // Vibrant coral-red
          secondary: Color(0xFFFF8C69), // Warm orange
          surface: Color(0xFF1A1A24), // Card surface
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.syne(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          displayMedium: GoogleFonts.syne(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          displaySmall: GoogleFonts.syne(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          headlineMedium: GoogleFonts.syne(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titleLarge: GoogleFonts.syne(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyLarge: GoogleFonts.dmSans(color: Colors.white70),
          bodyMedium: GoogleFonts.dmSans(color: Colors.white70),
        ),
        useMaterial3: true,
      ),
      // ✨ Restored to boot into your Splash Screen ✨
      home: const SplashScreen(),
    );
  }
}