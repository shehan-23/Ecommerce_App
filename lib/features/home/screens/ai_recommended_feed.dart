import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firebase_service.dart';
import '../../../models/product.dart';
import '../../products/screens/product_details_screen.dart';

class AiRecommendedFeed extends StatelessWidget {
  const AiRecommendedFeed({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();

    return StreamBuilder<DocumentSnapshot>(
      // Listens to the user's styleProfile created during the quiz
      stream: firebaseService.getUserProfileStream(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator(color: Color(0xFFFF4D6D))),
          );
        }

        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        final userData = userSnapshot.data!.data() as Map<String, dynamic>? ?? {};
        final styleProfile = userData['styleProfile'] as Map<String, dynamic>? ?? {};
        
        // Extract preferences for matching
        final userVibe = styleProfile['signatureVibe'] ?? 'Minimalist';
        final userGender = styleProfile['preferredGender'] ?? 'Unisex';

        return StreamBuilder<List<Product>>(
          stream: firebaseService.getProducts(),
          builder: (context, productSnapshot) {
            if (!productSnapshot.hasData) return const SizedBox.shrink();

            final allProducts = productSnapshot.data ?? [];
            
            // Filter and sort products based on AI Match Score
            final recommendedProducts = allProducts.where((product) {
              // Only show items that match or are neutral to target gender
              return product.targetGender == userGender || product.targetGender == "Unisex";
            }).toList();

            if (recommendedProducts.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: Color(0xFFFF4D6D), size: 18),
                          const SizedBox(width: 8),
                          Text(
                            "AI Curated For You",
                            style: GoogleFonts.syne(
                              fontSize: 20, 
                              fontWeight: FontWeight.bold, 
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Based on your $userVibe style profile",
                        style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white54),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: recommendedProducts.length,
                    itemBuilder: (context, index) {
                      final product = recommendedProducts[index];

                      // 🧠 Match Scoring Algorithm
                      int matchScore = 75; // Baseline
                      if (product.vibe == userVibe) matchScore += 20;
                      if (product.targetGender == userGender) matchScore += 4;
                      if (matchScore > 99) matchScore = 99;

                      return _buildRecommendationCard(context, product, matchScore);
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildRecommendationCard(BuildContext context, Product product, int score) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E26),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with Match Badge
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      image: DecorationImage(
                        image: NetworkImage(product.imageUrl ?? ''),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F0F14).withOpacity(0.85),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: score > 90 ? const Color(0xFFFF4D6D) : Colors.white24,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.bolt,
                            size: 14,
                            color: score > 90 ? const Color(0xFFFF4D6D) : Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "$score% MATCH",
                            style: GoogleFonts.syne(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Details Section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product.category.toUpperCase(),
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFF4D6D),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.syne(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rs. ${product.price.toStringAsFixed(0)}',
                      style: GoogleFonts.syne(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}