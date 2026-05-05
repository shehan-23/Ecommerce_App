import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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

  //add products
  Future<void> addProducts(String name, double price, String image) async {
    await _db.collection('products').add({
      'name': name,
      'price': price,
      'image': image,
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> removeFromCart(String docId) async {
    await _db.collection('cart').doc(docId).delete();
  }
}
