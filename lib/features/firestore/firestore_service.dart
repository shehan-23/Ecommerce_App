import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- USER PROFILE METHODS ---

  // SAVE USER DATA
  Future<void> saveUser(
    String uid,
    String email, {
    String firstName = '',
    String lastName = '',
    String phone = '',
  }) async {
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentSnapshot> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    return await _db.collection('users').doc(user.uid).get();
  }

  Future<void> updateUserAddress(Map<String, dynamic> addressMap) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    await _db.collection('users').doc(user.uid).update({
      'shippingAddress': addressMap,
    });
  }

  // --- PRODUCT METHODS ---

  Future<void> addProducts(String name, double price, String image) async {
    await _db.collection('products').add({
      'name': name,
      'price': price,
      'image': image,
      'createdAt': Timestamp.now(),
    });
  }

  // --- CART & ORDER METHODS ---

  Stream<QuerySnapshot> getOrderHistory() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    // Note: This requires a Firestore Composite Index
    return _db
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> removeFromCart(String docId) async {
    await _db.collection('carts').doc(docId).delete();
  }

  /// ATOMIC CHECKOUT PROCESS
  /// 1. Fetches current cart items
  /// 2. Creates an order record
  /// 3. Deletes items from the cart
  Future<void> checkout({
    required Map<String, dynamic> shippingAddress,
    required Map<String, dynamic> priceBreakdown,
    required DateTime estimatedDelivery,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final batch = _db.batch();

    // 1. Get the real items currently in the user's cart
    final cartSnapshot = await _db
        .collection('carts')
        .where('userId', isEqualTo: user.uid)
        .get();

    if (cartSnapshot.docs.isEmpty) {
      throw Exception("Cart is empty");
    }

    // Convert cart documents into a list of items for the order
    List<Map<String, dynamic>> orderItems = cartSnapshot.docs.map((doc) {
      final data = doc.data();
      data['cartDocId'] = doc.id; // Optional: keep track of original ID
      return data;
    }).toList();

    // 2. Create the real Order Document
    final orderRef = _db.collection('orders').doc();
    batch.set(orderRef, {
      'userId': user.uid,
      'orderId': orderRef.id.substring(0, 8).toUpperCase(),
      'items': orderItems,
      'shippingAddress': shippingAddress,
      'priceBreakdown': priceBreakdown,
      'totalPrice': priceBreakdown['total'], // Matches OrderScreen field
      'orderStatus': 'Processing',
      'createdAt': FieldValue.serverTimestamp(),
      'deliveryDate': Timestamp.fromDate(
        estimatedDelivery,
      ), // Matches OrderScreen field
    });

    // 3. Clear the Cart (delete all items for this user)
    for (var doc in cartSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // 4. Commit the transaction atomically
    await batch.commit();
  }
}
