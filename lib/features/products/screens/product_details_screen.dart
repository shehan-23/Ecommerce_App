import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Map product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {}, // Optional: Wishlist logic
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
                        image: NetworkImage(product['image']),
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
                      end: Alignment.center,
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 📄 Product Information Sheet
          Container(
            transform: Matrix4.translationValues(0.0, -30.0, 0.0),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F9FA),
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
                        product['name'],
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Text(
                      "Rs. ${product['price']}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFF5F6D),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    SizedBox(width: 5),
                    Text(
                      "4.8 (120 Reviews)",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                const Text(
                  "Description",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Crafted with premium materials, this item from SmartShop blends style and durability. Perfect for daily use or special occasions.",
                  style: TextStyle(
                    color: Colors.black54,
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Icon(
                        Icons.share_outlined,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5F6D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            await FirebaseFirestore.instance
                                .collection('cart')
                                .add({
                                  'userId': user.uid,
                                  'name': product['name'],
                                  'price': product['price'],
                                  'image': product['image'],
                                });
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: const Color(0xFFFF5F6D),
                                  content: Text(
                                    "${product['name']} added to cart!",
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        child: const Text(
                          "Add to Cart",
                          style: TextStyle(
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
