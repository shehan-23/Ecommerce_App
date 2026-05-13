import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../../models/product.dart';
import '../../../services/firebase_service.dart';
import 'glass_product_card.dart';
import '../../cart/screens/cart_screen.dart';
import '../../notifications/screens/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  String _searchQuery = "";
  String _selectedCategory = "All";

  final List<String> _categories = [
    "All",
    "T-Shirts",
    "Denim",
    "Jackets",
    "Hoodies",
    "Sneakers",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // #0F0F14
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(),
            _buildGreeting(),
            _buildSearchBar(),
            _buildCategorySelector(),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildPromoBanner()),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Featured",
                            style: GoogleFonts.syne(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                "See all",
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFFF4D6D),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_right_alt,
                                size: 14,
                                color: Color(0xFFFF4D6D),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    sliver: _buildProductGrid(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'SmartShop',
                style: GoogleFonts.syne(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF4D6D),
                ),
              ),
            ],
          ),
          Row(
            children: [
              // Notification icon
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Colors.white60,
                    size: 20,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              // Cart icon
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E26),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.white60,
                        size: 20,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CartScreen()),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF4D6D),
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '2',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Good morning ",
                style: GoogleFonts.dmSans(color: Colors.white54, fontSize: 14),
              ),
              const Text("👋", style: TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Find your style",
            style: GoogleFonts.syne(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E26),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            const Icon(Icons.search, color: Colors.white54, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.dmSans(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search your favorite styles",
                  hintStyle: GoogleFonts.dmSans(
                    color: Colors.white30,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (value) =>
                    setState(() => _searchQuery = value.toLowerCase()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4D6D),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.tune, color: Colors.white, size: 18),
                  onPressed: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = category),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFF4D6D)
                      : const Color(0xFF1E1E26),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  category,
                  style: GoogleFonts.dmSans(
                    color: isSelected ? Colors.white : Colors.white54,
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFDE3B59), // Base pink/red
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Background graphic circles
          Positioned(
            right: -20,
            bottom: -30,
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            right: 40,
            top: -20,
            child: Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "LIMITED OFFER",
                style: GoogleFonts.syne(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Get 30% off\nNew Arrivals",
                style: GoogleFonts.syne(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Explore the latest trends this season",
                style: GoogleFonts.dmSans(fontSize: 12, color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: Color(0xFFFF4D6D),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Shop Now",
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFF4D6D),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return StreamBuilder<List<Product>>(
      stream: _firebaseService.getProducts(category: _selectedCategory),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerGrid();
        }

        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Center(
              child: Text(
                "Error",
                style: GoogleFonts.dmSans(color: Colors.white),
              ),
            ),
          );
        }

        final products = snapshot.data ?? [];
        final filteredProducts = products.where((product) {
          final name = product.name.toLowerCase();
          return _searchQuery.isEmpty || name.contains(_searchQuery);
        }).toList();

        if (filteredProducts.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Center(
                child: Text(
                  "No items found",
                  style: GoogleFonts.dmSans(color: Colors.white54),
                ),
              ),
            ),
          );
        }

        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.58, // Adjust for new card content
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final product = filteredProducts[index];
            return GlassProductCard(
              productId: product.id,
              name: product.name,
              price: product.price,
              imageUrl: product.imageUrl,
              category: product.category,
            );
          }, childCount: filteredProducts.length),
        );
      },
    );
  }

  Widget _buildShimmerGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.58,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        return Shimmer.fromColors(
          baseColor: const Color(0xFF1A1A24),
          highlightColor: const Color(0xFF2A2A35),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A24),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      }, childCount: 4),
    );
  }
}
