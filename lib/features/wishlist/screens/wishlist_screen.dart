import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/firebase_service.dart';
import '../../../models/product.dart';
import '../../home/screens/glass_product_card.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F0F14),
        body: Center(
          child: Text(
            "Please log in to view wishlist.",
            style: GoogleFonts.dmSans(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Wishlist',
          style: GoogleFonts.syne(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Product>>(
        stream: _firebaseService.getWishlistedProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF4D6D)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error fetching wishlist",
                style: GoogleFonts.dmSans(color: Colors.white),
              ),
            );
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.white24,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Your Wishlist is Empty",
                    style: GoogleFonts.syne(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Like items you want to buy later.",
                    style: GoogleFonts.dmSans(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.58,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return GlassProductCard(
                productId: product.id,
                name: product.name,
                price: product.price,
                imageUrl: product.imageUrl,
                category: product.category,
              );
            },
          );
        },
      ),
    );
  }
}
