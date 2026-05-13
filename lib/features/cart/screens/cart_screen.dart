import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/firebase_service.dart';
import '../../orders/screens/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),
      appBar: AppBar(
        title: Text(
          'Your Cart',
          style: GoogleFonts.syne(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firebaseService.getCartStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF4D6D)),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Error fetching cart",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final cartItems = snapshot.data?.docs ?? [];

          if (cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.white38,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Your Cart is Empty",
                    style: GoogleFonts.syne(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          double total = 0;
          for (var doc in cartItems) {
            final data = doc.data() as Map<String, dynamic>;
            total += (data['price'] * data['quantity']);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final itemDoc = cartItems[index];
                    final item = itemDoc.data() as Map<String, dynamic>;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E26),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                image: NetworkImage(item['imageUrl'] ?? ''),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'],
                                  style: GoogleFonts.syne(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "\$${item['price']}",
                                  style: GoogleFonts.syne(
                                    color: const Color(0xFFFF4D6D),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                "x${item['quantity']}",
                                style: GoogleFonts.dmSans(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () =>
                                    firebaseService.removeFromCart(itemDoc.id),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Checkout section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E1E26),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Total",
                            style: GoogleFonts.dmSans(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "\$${total.toStringAsFixed(2)}",
                            style: GoogleFonts.syne(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF4D6D),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CheckoutScreen(subtotal: total),
                            ),
                          );
                        },
                        child: Text(
                          "Checkout",
                          style: GoogleFonts.syne(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
