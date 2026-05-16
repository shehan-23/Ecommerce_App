import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../services/firebase_service.dart';
import '../../../models/address_model.dart';
import '../../navigation/main_wrapper.dart';

class CheckoutScreen extends StatefulWidget {
  final double subtotal;

  const CheckoutScreen({super.key, required this.subtotal});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipController;

  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = true;
  bool _isProcessing = false;

  final double shippingFee = 350.0;
  late double tax;
  late double totalAmount;

  @override
  void initState() {
    super.initState();
    _streetController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _zipController = TextEditingController();

    tax = widget.subtotal * 0.05;
    totalAmount = widget.subtotal + shippingFee + tax;

    _loadUserAddress();
  }

  Future<void> _loadUserAddress() async {
    try {
      final userDoc = await _firebaseService.getUserProfile();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        if (data.containsKey('shippingAddress')) {
          final address = AddressModel.fromMap(data['shippingAddress']);
          _streetController.text = address.street;
          _cityController.text = address.city;
          _stateController.text = address.state;
          _zipController.text = address.zipCode;
        }
      }
    } catch (e) {
      debugPrint("Address fetch error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  DateTime _calculateEstimatedDelivery() {
    return DateTime.now().add(const Duration(days: 4));
  }

  Future<void> _handleCheckout() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      final address = AddressModel(
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        zipCode: _zipController.text.trim(),
      );

      // Save user address
      await _firebaseService.updateUserAddress(address.toMap());

      // Prepare breakdown
      final priceBreakdown = {
        'subtotal': widget.subtotal,
        'shippingFee': shippingFee,
        'tax': tax,
        'total': totalAmount,
      };

      // Execute Checkout
      await _firebaseService.checkout(
        shippingAddress: address.toMap(),
        priceBreakdown: priceBreakdown,
        estimatedDelivery: _calculateEstimatedDelivery(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Payment Successful! Order placed.", style: GoogleFonts.dmSans()),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigationWrapper()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Checkout failed: $e", style: GoogleFonts.dmSans()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final estimatedDelivery = _calculateEstimatedDelivery();
    final formatter = DateFormat('MMM dd, yyyy');

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),
      appBar: AppBar(
        title: Text('Checkout', style: GoogleFonts.syne(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF4D6D)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Shipping Address", style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E26),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        children: [
                          _buildTextField(_streetController, "Street Address"),
                          const SizedBox(height: 12),
                          _buildTextField(_cityController, "City"),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildTextField(_stateController, "State")),
                              const SizedBox(width: 12),
                              Expanded(child: _buildTextField(_zipController, "Zip Code", isNumber: true)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4D6D).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFFFF4D6D).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_shipping_outlined, color: Color(0xFFFF4D6D)),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Estimated Delivery", style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 13)),
                              Text("Arriving by ${formatter.format(estimatedDelivery)}", style: GoogleFonts.syne(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text("Order Summary", style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        _buildSummaryRow("Subtotal", widget.subtotal),
                        const SizedBox(height: 8),
                        _buildSummaryRow("Shipping Fee", shippingFee),
                        const SizedBox(height: 8),
                        _buildSummaryRow("Estimated Tax", tax),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.black12, thickness: 1)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total Amount", style: GoogleFonts.syne(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
                            Text("Rs. ${totalAmount.toStringAsFixed(2)}", style: GoogleFonts.syne(color: const Color(0xFFFF4D6D), fontSize: 22, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4D6D),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 10,
                        shadowColor: const Color(0xFFFF4D6D).withOpacity(0.5),
                      ),
                      onPressed: _isProcessing ? null : _handleCheckout,
                      child: _isProcessing
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text("Pay Now", style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (value) => value == null || value.trim().isEmpty ? "Required" : null,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFF4D6D))),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.dmSans(color: Colors.black54, fontSize: 15)),
        Text("Rs. ${amount.toStringAsFixed(2)}", style: GoogleFonts.dmSans(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }
}