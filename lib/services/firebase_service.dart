import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserUid => _auth.currentUser?.uid;

  // 1. Fetch products with optional category filtering
  Stream<List<Product>> getProducts({String category = "All"}) {
    Query query = _firestore.collection('products');
    if (category != "All") {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  // 2. Wishlist Logic
  Future<void> toggleWishlist(
    String productId,
    bool isCurrentlyWishlisted,
  ) async {
    final uid = currentUserUid;
    if (uid == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .doc(productId);

    if (isCurrentlyWishlisted) {
      await docRef.delete();
    } else {
      await docRef.set({
        'addedAt': FieldValue.serverTimestamp(),
        'productId': productId,
      });
    }
  }

  Stream<List<String>> getWishlistIds() {
    final uid = currentUserUid;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.id).toList();
        });
  }

  Stream<List<Product>> getWishlistedProducts() {
    return getWishlistIds().asyncMap((ids) async {
      if (ids.isEmpty) return [];
      // Note: `whereIn` accepts up to 10 elements. For production, chunk the requests.
      final docSnaps = await _firestore
          .collection('products')
          .where(FieldPath.documentId, whereIn: ids)
          .get();
      return docSnaps.docs
          .map((doc) => Product.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // 3. Cart Logic
  Stream<QuerySnapshot> getCartStream() {
    final uid = currentUserUid;
    if (uid == null) return const Stream.empty();
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('cart')
        .snapshots();
  }

  Future<void> addToCart(
    String productId,
    String name,
    double price,
    String? imageUrl, {
    int quantity = 1,
  }) async {
    final uid = currentUserUid;
    if (uid == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('cart')
        .doc(productId);

    await docRef.set({
      'productId': productId,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': FieldValue.increment(quantity),
      'addedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> removeFromCart(String productId) async {
    final uid = currentUserUid;
    if (uid == null) return;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('cart')
        .doc(productId)
        .delete();
  }

  Future<void> checkout({
    required Map<String, dynamic> shippingAddress,
    required Map<String, dynamic> priceBreakdown,
    required DateTime estimatedDelivery,
  }) async {
    final uid = currentUserUid;
    if (uid == null) return;

    final cartSnap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('cart')
        .get();
    if (cartSnap.docs.isEmpty) return;

    List<Map<String, dynamic>> items = [];

    for (var doc in cartSnap.docs) {
      final data = doc.data();
      items.add(data);
    }

    // Create order
    await _firestore.collection('orders').add({
      'userId': uid,
      'items': items,
      'totalPrice': priceBreakdown['total'],
      'priceBreakdown': priceBreakdown,
      'shippingAddress': shippingAddress,
      'deliveryDate': Timestamp.fromDate(estimatedDelivery),
      'orderStatus': 'Processing', // Can be 'Shipped', 'Out for Delivery'
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Clear cart batched
    final batch = _firestore.batch();
    for (var doc in cartSnap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // 4. Notifications Logic
  Stream<QuerySnapshot> getNotificationsStream() {
    final uid = currentUserUid;
    if (uid == null) return const Stream.empty();
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // 5. Order History Logic
  Stream<QuerySnapshot> getOrderHistory() {
    final uid = currentUserUid;
    if (uid == null) return const Stream.empty();

    // Removing orderBy to allow fetching without a composite index.
    // We will handle the descending sort client-side in the OrderScreen.
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: uid)
        .snapshots();
  }

  // 6. User Profile Logic
  Future<DocumentSnapshot> getUserProfile() async {
    final uid = currentUserUid;
    if (uid == null) throw Exception("User not authenticated");
    return _firestore.collection('users').doc(uid).get();
  }

  Stream<DocumentSnapshot> getUserProfileStream() {
    final uid = currentUserUid;
    if (uid == null) return const Stream.empty();
    return _firestore.collection('users').doc(uid).snapshots();
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
  }) async {
    final uid = currentUserUid;
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'phone': phone,
    }, SetOptions(merge: true));
  }

  Future<void> updateUserAddress(Map<String, dynamic> address) async {
    final uid = currentUserUid;
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).set({
      'shippingAddress': address,
    }, SetOptions(merge: true));
  }
}
