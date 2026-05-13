class Product {
  final String id;
  final String name;
  final double price;
  final String? imageUrl;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.imageUrl,
  });

  factory Product.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Product(
      id: documentId,
      name: data['name'] ?? 'Unknown Product',
      price: (data['price'] ?? 0.0).toDouble(),
      category: data['category'] ?? 'All',
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
    };
  }
}
