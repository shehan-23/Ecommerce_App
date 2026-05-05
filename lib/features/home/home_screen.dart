import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/auth_service.dart';
import 'package:smartshop/features/products/screens/add_product_screen.dart';
import 'package:smartshop/features/cart/screens/cart_screen.dart';
import '../ordes/screens/order_screen.dart';
import '../products/screens/product_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _auth = AuthService();
  String searchText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Clean light background
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "SmartShop",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OrderScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CartScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async => await _auth.signOut(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 🎨 Header Gradient Background
          Container(
            height: 220,
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
            child: Column(
              children: [
                // 🔍 Improved Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (value) =>
                          setState(() => searchText = value.toLowerCase()),
                      decoration: InputDecoration(
                        hintText: "Search your favorite styles...",
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFFFF5F6D),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),

                // 🔥 Dynamic Product List
                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('products')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            "No products available",
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      var products = snapshot.data!.docs.where((doc) {
                        String name = doc.data().containsKey('name')
                            ? doc['name'].toString().toLowerCase()
                            : "";
                        return name.contains(searchText);
                      }).toList();

                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                                  2, // ✅ Changed to 2 for better readability
                              childAspectRatio: 0.72,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                            ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final productData = products[index].data();
                          final String name = productData['name'] ?? 'No Name';
                          final String price =
                              productData['price']?.toString() ?? '0';
                          final String imageUrl =
                              productData['image'] ??
                              'https://via.placeholder.com/150';

                          return ProductCard(
                            name: name,
                            price: price,
                            imageUrl: imageUrl,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailsScreen(product: productData),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFF5F6D),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddProductScreen()),
        ),
        label: const Text(
          "Add Item",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ✅ Refactored Product Card for a Premium Look
class ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String imageUrl;
  final VoidCallback onTap;

  const ProductCard({super.key, 
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      radius: 15,
                      child: const Icon(
                        Icons.favorite_border,
                        size: 18,
                        color: Color(0xFFFF5F6D),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Product Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Rs. $price",
                    style: const TextStyle(
                      color: Color(0xFFFF5F6D),
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Add to Cart Small Button
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEEAE6),
                        foregroundColor: const Color(0xFFFF5F6D),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () async {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          await FirebaseFirestore.instance
                              .collection('cart')
                              .add({
                                'userId': user.uid,
                                'name': name,
                                'price': price,
                                'image': imageUrl,
                              });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("$name added to cart!"),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "Add",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
