import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Add intl to your pubspec.yaml

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "My Orders",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // 🎨 Consistent Gradient Header
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
                  .collection('orders')
                  .where('userId', isEqualTo: user!.uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyOrdersState();
                }

                var orders = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  itemCount: orders.length,
                  itemBuilder: (context, index) =>
                      OrderCard(order: orders[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyOrdersState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "No orders yet",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final QueryDocumentSnapshot order;
  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // Format the Firestore Timestamp
    String formattedDate = "";
    if (order['createdAt'] != null) {
      DateTime date = (order['createdAt'] as Timestamp).toDate();
      formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(date);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          title: Text(
            "Total: Rs. ${order['total'].toStringAsFixed(2)}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            formattedDate,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          trailing: const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFFFF5F6D),
          ),
          children: [
            const Divider(height: 1, indent: 20, endIndent: 20),
            ...(order['items'] as List).map((item) {
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item['image'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  item['name'],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text("Rs. ${item['price']}"),
              );
            }).toList(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
