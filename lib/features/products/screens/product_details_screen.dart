import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/firebase_service.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Map product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();
    // Default fallback if fields are missing
    final String productId =
        product['id'] ??
        product['name'] ??
        DateTime.now().millisecondsSinceEpoch.toString();

    return Scaffold(
      backgroundColor: const Color(
        0xFF0F0F14,
      ), // Coral-Orange premium dark theme
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          StreamBuilder<List<String>>(
            stream: firebaseService.getWishlistIds(),
            builder: (context, snapshot) {
              final wishlist = snapshot.data ?? [];
              final isWishlisted = wishlist.contains(productId);
              return IconButton(
                icon: Icon(
                  isWishlisted ? Icons.favorite : Icons.favorite_border,
                  color: isWishlisted ? const Color(0xFFFF4D6D) : Colors.white,
                ),
                onPressed: () =>
                    firebaseService.toggleWishlist(productId, isWishlisted),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 🎨 Immersive Product Image with Gradient Overlay
          Expanded(
            child: Stack(
              children: [
                Hero(
                  tag: 'product-${product['name']}',
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          product['image'] ?? product['imageUrl'] ?? '',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                // Soft gradient overlay to make back button visible
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                        const Color(0xFF0F0F14).withOpacity(0.9),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 📄 Product Information Sheet
          Container(
            transform: Matrix4.translationValues(0.0, -20.0, 0.0),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E26), // Surface dark
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product['name'] ?? 'Unknown',
                        style: GoogleFonts.syne(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      "\$${product['price']}",
                      style: GoogleFonts.syne(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFFF4D6D), // Coral red
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 5),
                    Text(
                      "4.8 (120 Reviews)",
                      style: GoogleFonts.dmSans(color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Text(
                  "Description",
                  style: GoogleFonts.syne(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Crafted with premium materials, this item from SmartShop blends style and durability. Perfect for daily use or special occasions.",
                  style: GoogleFonts.dmSans(
                    color: Colors.white70,
                    height: 1.5,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 40),

                // 🛒 Action Button Section
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A35),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: const Icon(
                        Icons.share_outlined,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF4D6D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 10,
                          shadowColor: const Color(0xFFFF4D6D).withOpacity(0.5),
                        ),
                        onPressed: () async {
                          try {
                            // Safely parse price just in case it was passed as a String from the UI Map
                            final parsedPrice =
                                double.tryParse(product['price'].toString()) ??
                                0.0;

                            await firebaseService.addToCart(
                              productId,
                              product['name'] ?? 'Item',
                              parsedPrice,
                              product['image'] ?? product['imageUrl'],
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: const Color(0xFF1E1E26),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  content: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: Color(0xFFFF4D6D),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          "${product['name']} added to cart!",
                                          style: GoogleFonts.dmSans(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            debugPrint("Cart Error: $e");
                          }
                        },
                        child: Text(
                          "Add to Cart",
                          style: GoogleFonts.syne(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
