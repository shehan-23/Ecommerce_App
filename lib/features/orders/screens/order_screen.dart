import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../services/firebase_service.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),
      appBar: AppBar(
        title: Text(
          'Order History',
          style: GoogleFonts.syne(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Ensure getOrderHistory() is returning the stream correctly
        stream: firebaseService.getOrderHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF4D6D)),
            );
          }

          if (snapshot.hasError) {
            // Debugging: Print the error to the console to find the Index URL
            debugPrint("Firestore Error: ${snapshot.error}");
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Error: Check console for index requirements",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(color: Colors.white70),
                ),
              ),
            );
          }

          final orders = snapshot.data?.docs ?? [];

          if (orders.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final doc = orders[index];
              final orderData = doc.data() as Map<String, dynamic>;

              // Extract fields with fallbacks to avoid crashes
              final orderId = doc.id.substring(0, 8).toUpperCase();
              final items = orderData['items'] as List<dynamic>? ?? [];
              final status = orderData['orderStatus'] ?? 'Processing';
              final totalPrice = orderData['totalPrice'] ?? 0.0;
              final deliveryDate = orderData['deliveryDate'] as Timestamp?;

              return _buildOrderCard(
                orderId,
                status,
                items.length,
                totalPrice,
                deliveryDate,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(
    String id,
    String status,
    int itemCount,
    dynamic price,
    Timestamp? delivery,
  ) {
    Color statusColor;
    switch (status) {
      case 'Shipped':
        statusColor = Colors.blueAccent;
        break;
      case 'Out for Delivery':
        statusColor = const Color(0xFFFF4D6D);
        break;
      case 'Delivered':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.orangeAccent;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Order #$id",
                style: GoogleFonts.syne(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              _buildStatusBadge(status, statusColor),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "$itemCount ${itemCount == 1 ? 'item' : 'items'}",
            style: GoogleFonts.dmSans(color: Colors.white70),
          ),
          if (delivery != null) ...[
            const SizedBox(height: 8),
            Text(
              "Arriving by ${DateFormat('MMM dd, yyyy').format(delivery.toDate())}",
              style: GoogleFonts.dmSans(
                color: const Color(0xFFFFD166),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const Divider(height: 24, color: Colors.white10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Amount",
                style: GoogleFonts.dmSans(color: Colors.white70),
              ),
              Text(
                "\$${price.toString()}",
                style: GoogleFonts.syne(
                  color: const Color(0xFFFF4D6D),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status,
        style: GoogleFonts.dmSans(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.white38,
          ),
          const SizedBox(height: 20),
          Text(
            "No orders yet",
            style: GoogleFonts.syne(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
