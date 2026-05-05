import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "My Shopping Cart",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // 🎨 Background Header
          Container(
            height: 180,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF5F6D), Color(0xFFFF8A65)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          SafeArea(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('cart')
                  .where('userId', isEqualTo: user!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                var items = snapshot.data!.docs;
                double total = items.fold(
                  0,
                  (sum, item) => sum + (item['price'] ?? 0),
                );

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                        itemCount: items.length,
                        itemBuilder: (context, index) =>
                            CartItemCard(item: items[index]),
                      ),
                    ),
                    _buildCheckoutPanel(context, items, total, user.uid),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ✨ Modern Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_basket_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            "Your cart feels a bit light!",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Add some items to get started.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // 💰 Stylized Bottom Panel
  Widget _buildCheckoutPanel(
    BuildContext context,
    List<QueryDocumentSnapshot> items,
    double total,
    String uid,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Subtotal",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "Rs. ${total.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF5F6D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5F6D),
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 0,
            ),
            onPressed: () => _handleCheckout(context, items, total, uid),
            child: const Text(
              "Place Order",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🚀 Optimized Checkout with Write Batch
  Future<void> _handleCheckout(
    BuildContext context,
    List<QueryDocumentSnapshot> items,
    double total,
    String uid,
  ) async {
    final batch = FirebaseFirestore.instance.batch();

    // 1. Create Order
    DocumentReference orderRef = FirebaseFirestore.instance
        .collection('orders')
        .doc();
    batch.set(orderRef, {
      'userId': uid,
      'items': items
          .map(
            (i) => {
              'name': i['name'],
              'price': i['price'],
              'image': i['image'],
            },
          )
          .toList(),
      'total': total,
      'createdAt': Timestamp.now(),
    });

    // 2. Clear Cart (Batching multiple deletes is faster)
    for (var doc in items) {
      batch.delete(doc.reference);
    }

    try {
      await batch.commit();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Order successful!"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Checkout failed. Try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class CartItemCard extends StatelessWidget {
  final QueryDocumentSnapshot item;
  const CartItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              item['image'],
              width: 75,
              height: 75,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Rs. ${item['price']}",
                  style: const TextStyle(
                    color: Color(0xFFFF5F6D),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
            onPressed: () => item.reference.delete(),
          ),
        ],
      ),
    );
  }
}
