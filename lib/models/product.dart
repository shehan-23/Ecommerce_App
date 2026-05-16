class Product {
  final String id;
  final String name;
  final double price;
  final String? imageUrl;
  final String category;
  
  // ✨ NEW: AI Features Data ✨
  final Map<String, dynamic>? sizeMatrix; // For the Size Recommender
  final String? vibe;                     // For the AI Style Feed (e.g., Streetwear)
  final String? targetGender;             // For the AI Style Feed (e.g., Menswear)

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.imageUrl,
    this.sizeMatrix,
    this.vibe,
    this.targetGender,
  });

  factory Product.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Product(
      id: documentId,
      name: data['name'] ?? 'Unknown Product',
      price: (data['price'] ?? 0.0).toDouble(),
      category: data['category'] ?? 'All',
      // The Fix: Checks for both keys to prevent blank images
      imageUrl: data['image'] ?? data['imageUrl'], 
      
      // ✨ Map new AI fields from Firestore ✨
      sizeMatrix: data['sizeMatrix'] as Map<String, dynamic>?,
      vibe: data['vibe'] as String?,
      targetGender: data['targetGender'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'sizeMatrix': sizeMatrix,
      'vibe': vibe,
      'targetGender': targetGender,
    };
  }
}