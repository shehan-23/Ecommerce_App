import 'package:flutter/material.dart';
import '../../firestore/firestore_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageController = TextEditingController();

  final FirestoreService _firestore = FirestoreService();

  String message = '';
  bool isSuccess = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Add New Product",
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
            height: 200,
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // 📦 Form Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: nameController,
                          label: "Product Name",
                          icon: Icons.shopping_bag_outlined,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: priceController,
                          label: "Price (Rs.)",
                          icon: Icons.payments_outlined,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: imageController,
                          label: "Image URL",
                          icon: Icons.link_rounded,
                        ),
                        const SizedBox(height: 30),

                        // 🔘 Action Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF5F6D),
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _submitForm,
                          child: const Text(
                            "Publish Product",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 📩 Status Message
                  if (message.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: isSuccess
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSuccess
                              ? Colors.green.shade200
                              : Colors.red.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSuccess
                                ? Icons.check_circle
                                : Icons.error_outline,
                            color: isSuccess ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              message,
                              style: TextStyle(
                                color: isSuccess
                                    ? Colors.green.shade800
                                    : Colors.red.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🛠 Helper to build consistent TextFields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFFF5F6D)),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        floatingLabelStyle: const TextStyle(color: Color(0xFFFF5F6D)),
      ),
    );
  }

  // 🚀 Logic handled here
  Future<void> _submitForm() async {
    double? price = double.tryParse(priceController.text.trim());

    if (nameController.text.isEmpty ||
        price == null ||
        imageController.text.isEmpty) {
      setState(() {
        isSuccess = false;
        message = "Please fill all fields with valid data!";
      });
      return;
    }

    await _firestore.addProducts(
      nameController.text.trim(),
      price,
      imageController.text.trim(),
    );

    setState(() {
      isSuccess = true;
      message = "Product published successfully!";
      nameController.clear();
      priceController.clear();
      imageController.clear();
    });
  }
}
