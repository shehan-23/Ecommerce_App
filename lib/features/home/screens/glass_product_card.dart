import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/firebase_service.dart';

class GlassProductCard extends StatelessWidget {
  final String productId;
  final String name;
  final double price;
  final String? imageUrl;
  final String category; // Needed for the 'TOPS' label

  const GlassProductCard({
    super.key,
    required this.productId,
    required this.name,
    required this.price,
    this.imageUrl,
    this.category = "CATEGORY",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E26), // Card Surface color
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Graphic / Image Region
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF262633), // Darker image background
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: imageUrl != null && imageUrl!.isNotEmpty
                        ? Image.network(imageUrl!, fit: BoxFit.cover)
                        : Icon(
                            Icons.checkroom,
                            size: 50,
                            color: Colors.white.withOpacity(0.1),
                          ),
                  ),
                ),
                // Badge "NEW" (or "HOT")
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD166), // Yellow accent
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'NEW',
                      style: GoogleFonts.syne(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                // Wishlist Button
                Positioned(
                  top: 12,
                  right: 12,
                  child: WishlistButton(productId: productId),
                ),
              ],
            ),
          ),
          // Product Info
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.toUpperCase(),
                  style: GoogleFonts.dmSans(
                    fontSize: 9,
                    color: Colors.white60,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.syne(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star_border,
                      color: Color(0xFFFFD166),
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Rs. ${price.toStringAsFixed(0)}',
                              style: GoogleFonts.syne(
                                color: const Color(0xFFFF4D6D),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Rs. ${(price * 1.3).toStringAsFixed(0)}',
                              style: GoogleFonts.dmSans(
                                color: Colors.white30,
                                fontSize: 10,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () async {
                        try {
                          await FirebaseService().addToCart(
                            productId,
                            name,
                            price,
                            imageUrl,
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
                                        "$name added to cart!",
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
                      child: Container(
                        height: 28,
                        width: 28,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 18,
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

class WishlistButton extends StatelessWidget {
  final String productId;

  const WishlistButton({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: FirebaseService().getWishlistIds(),
      builder: (context, snapshot) {
        final wishlistedIds = snapshot.data ?? [];
        final isLiked = wishlistedIds.contains(productId);

        return GestureDetector(
          onTap: () async {
            if (FirebaseAuth.instance.currentUser == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please log in to add to wishlist.'),
                ),
              );
              return;
            }
            await FirebaseService().toggleWishlist(productId, isLiked);
          },
          child: Container(
            height: 28,
            width: 28,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24),
            ),
            child: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? const Color(0xFFFF4D6D) : Colors.white70,
              size: 14,
            ),
          ),
        );
      },
    );
  }
}
