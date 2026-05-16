import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StyleQuizScreen extends StatefulWidget {
  const StyleQuizScreen({super.key});

  @override
  State<StyleQuizScreen> createState() => _StyleQuizScreenState();
}

class _StyleQuizScreenState extends State<StyleQuizScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Storing the user's selections
  String? selectedGender;
  String? selectedVibe;
  List<String> selectedColors = [];

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // TODO: Save preferences to Firestore and navigate to Home Screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI Profile Built! Welcome to Fitkarma.')),
      );
      Navigator.pop(context); // Replace with actual navigation to your Home Screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14), // Premium dark background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              )
            : null,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Skip logic
            child: Text(
              "Skip",
              style: GoogleFonts.dmSans(color: Colors.white54, fontSize: 16),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
              child: Row(
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 4,
                      decoration: BoxDecoration(
                        color: _currentPage >= index
                            ? const Color(0xFFFF4D6D) // Coral active
                            : Colors.white24, // Inactive
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            
            // Quiz Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Disable manual swipe
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildGenderPage(),
                  _buildVibePage(),
                  _buildColorsPage(),
                ],
              ),
            ),

            // Next / Finish Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4D6D),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                  shadowColor: const Color(0xFFFF4D6D).withOpacity(0.4),
                ),
                onPressed: _nextPage,
                child: Text(
                  _currentPage == 2 ? "Build My AI Profile" : "Continue",
                  style: GoogleFonts.syne(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- PAGE 1: GENDER / FIT ---
  Widget _buildGenderPage() {
    return _buildPageLayout(
      title: "Who are you shopping for?",
      subtitle: "This helps us tailor your Fitkarma experience.",
      content: Column(
        children: [
          _buildSelectionCard("Menswear", Icons.man, selectedGender == "Menswear", () {
            setState(() => selectedGender = "Menswear");
          }),
          const SizedBox(height: 16),
          _buildSelectionCard("Womenswear", Icons.woman, selectedGender == "Womenswear", () {
            setState(() => selectedGender = "Womenswear");
          }),
          const SizedBox(height: 16),
          _buildSelectionCard("Everyone / Unisex", Icons.people_alt_outlined, selectedGender == "Unisex", () {
            setState(() => selectedGender = "Unisex");
          }),
        ],
      ),
    );
  }

  // --- PAGE 2: STYLE VIBE ---
  Widget _buildVibePage() {
    return _buildPageLayout(
      title: "What's your signature vibe?",
      subtitle: "Pick the style that speaks to you most.",
      content: Column(
        children: [
          _buildSelectionCard("Streetwear & Casual", Icons.skateboarding, selectedVibe == "Streetwear", () {
            setState(() => selectedVibe = "Streetwear");
          }),
          const SizedBox(height: 16),
          _buildSelectionCard("Minimalist & Clean", Icons.checkroom, selectedVibe == "Minimalist", () {
            setState(() => selectedVibe = "Minimalist");
          }),
          const SizedBox(height: 16),
          _buildSelectionCard("Athleisure & Gym", Icons.fitness_center, selectedVibe == "Athleisure", () {
            setState(() => selectedVibe = "Athleisure");
          }),
        ],
      ),
    );
  }

  // --- PAGE 3: COLORS ---
  Widget _buildColorsPage() {
    final colors = ["Monochrome", "Earth Tones", "Pastels", "Vibrant & Bold", "Dark & Moody"];
    
    return _buildPageLayout(
      title: "Which palettes do you gravitate toward?",
      subtitle: "Select as many as you like.",
      content: Wrap(
        spacing: 12,
        runSpacing: 16,
        children: colors.map((color) {
          final isSelected = selectedColors.contains(color);
          return GestureDetector(
            onTap: () {
              setState(() {
                isSelected ? selectedColors.remove(color) : selectedColors.add(color);
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFF4D6D).withOpacity(0.15) : const Color(0xFF1E1E26),
                border: Border.all(
                  color: isSelected ? const Color(0xFFFF4D6D) : Colors.white10,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                color,
                style: GoogleFonts.dmSans(
                  color: isSelected ? const Color(0xFFFF4D6D) : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- REUSABLE UI BUILDERS ---
  Widget _buildPageLayout({required String title, required String subtitle, required Widget content}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(title, style: GoogleFonts.syne(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2)),
          const SizedBox(height: 12),
          Text(subtitle, style: GoogleFonts.dmSans(fontSize: 16, color: Colors.white60)),
          const SizedBox(height: 40),
          content,
        ],
      ),
    );
  }

  Widget _buildSelectionCard(String title, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF4D6D).withOpacity(0.1) : const Color(0xFF1E1E26),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF4D6D) : Colors.white10,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFFFF4D6D) : Colors.white54, size: 28),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.syne(
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.white70,
              ),
            ),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: Color(0xFFFF4D6D)),
          ],
        ),
      ),
    );
  }
}