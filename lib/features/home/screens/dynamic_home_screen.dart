import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../../models/product.dart';
import '../../../services/firebase_service.dart';
import 'glass_product_card.dart';
import 'ai_recommended_feed.dart'; // Added
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

  // Updated categories to match our AI Vibe logic
  final List<String> _categories = [
    "All",
    "Streetwear",
    "Minimalist",
    "Athleisure",
    "Outerwear",
    "Hoodies",
    "Sneakers",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14), 
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
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ✨ AI Recommended Feed placed prominently at the top
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: AiRecommendedFeed(),
                    ),
                  ),
                  
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
                            _selectedCategory == "All" ? "Featured" : "$_selectedCategory Collection",
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
                  const SliverToBoxAdapter(child: SizedBox(height: 30)),
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
          Text(
            'FitKarma',
            style: GoogleFonts.syne(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFF4D6D),
            ),
          ),
          Row(
            children: [
              _buildIconButton(Icons.notifications_none, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
              }),
              const SizedBox(width: 10),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildIconButton(Icons.shopping_cart_outlined, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                  }),
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Color(0xFFFF4D6D), shape: BoxShape.circle),
                      child: const Text('2', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
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

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return Container(
      height: 36,
      width: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E26),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: Colors.white60, size: 20),
        onPressed: onTap,
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
              Text("Good morning ", style: GoogleFonts.dmSans(color: Colors.white54, fontSize: 14)),
              const Text("👋", style: TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Find your style",
            style: GoogleFonts.syne(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
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
                  hintStyle: GoogleFonts.dmSans(color: Colors.white30, fontSize: 14),
                  border: InputBorder.none,
                ),
                onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(color: const Color(0xFFFF4D6D), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.tune, color: Colors.white, size: 18),
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
                  color: isSelected ? const Color(0xFFFF4D6D) : const Color(0xFF1E1E26),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  category,
                  style: GoogleFonts.dmSans(
                    color: isSelected ? Colors.white : Colors.white54,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
        color: const Color(0xFFDE3B59), 
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("LIMITED OFFER", style: GoogleFonts.syne(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text("Get 30% off\nNew Arrivals", style: GoogleFonts.syne(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Text("Shop Now", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: const Color(0xFFFF4D6D), fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return StreamBuilder<List<Product>>(
      stream: _firebaseService.getProducts(category: _selectedCategory),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return _buildShimmerGrid();
        
        final products = snapshot.data ?? [];
        final filteredProducts = products.where((p) => _searchQuery.isEmpty || p.name.toLowerCase().contains(_searchQuery)).toList();

        if (filteredProducts.isEmpty) {
          return const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(40), child: Text("No items found", style: TextStyle(color: Colors.white54)))));
        }

        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.62, // Adjusted for GlassProductCard
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            return GlassProductCard(product: filteredProducts[index]);
          }, childCount: filteredProducts.length),
        );
      },
    );
  }

  Widget _buildShimmerGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.62, crossAxisSpacing: 16, mainAxisSpacing: 16),
      delegate: SliverChildBuilderDelegate((context, index) => Shimmer.fromColors(
        baseColor: const Color(0xFF1A1A24),
        highlightColor: const Color(0xFF2A2A35),
        child: Container(decoration: BoxDecoration(color: const Color(0xFF1A1A24), borderRadius: BorderRadius.circular(16))),
      ), childCount: 4),
    );
  }
}