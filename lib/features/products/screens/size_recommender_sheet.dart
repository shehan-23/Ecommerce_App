import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SizeRecommenderSheet extends StatefulWidget {
  final String productName;
  final Map<String, dynamic>? sizeMatrix;

  const SizeRecommenderSheet({
    super.key,
    required this.productName,
    this.sizeMatrix,
  });

  @override
  State<SizeRecommenderSheet> createState() => _SizeRecommenderSheetState();
}

class _SizeRecommenderSheetState extends State<SizeRecommenderSheet> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  
  String _recommendedSize = "";
  String _fitNote = "";

  void _calculateSize() {
    double? height = double.tryParse(_heightController.text);
    double? weight = double.tryParse(_weightController.text);

    if (height == null || weight == null) return;

    // 🧠 FitKarma Smart Logic
    // We estimate required chest width based on weight/height ratio
    double estimatedBodyChest = (weight * 0.5) + (height * 0.1);

    String bestSize = "M"; // Default fallback
    String note = "Standard Fit";

    if (widget.sizeMatrix != null && widget.sizeMatrix!.isNotEmpty) {
      double minDiff = 999;

      widget.sizeMatrix!.forEach((size, measurements) {
        double garmentChest = (measurements['chest'] as num).toDouble();
        // We look for a garment that is 2-4 inches wider than the body for a good fit
        double diff = (garmentChest - estimatedBodyChest).abs();
        
        if (diff < minDiff) {
          minDiff = diff;
          bestSize = size;
        }
      });

      if (minDiff < 2) {
        note = "Tailored Fit: This will be a snug, premium fit.";
      } else {
        note = "Relaxed Fit: Comfortable and slightly loose.";
      }
    } else {
      // Fallback if no matrix exists
      if (weight < 60) bestSize = "S";
      else if (weight < 75) bestSize = "M";
      else if (weight < 90) bestSize = "L";
      else bestSize = "XL";
      note = "Estimated based on average proportions.";
    }

    setState(() {
      _recommendedSize = bestSize;
      _fitNote = note;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E26),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Smart Size Engine",
            style: GoogleFonts.syne(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Finding your fit for ${widget.productName}",
            style: GoogleFonts.dmSans(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration("Height (cm)", Icons.height),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration("Weight (kg)", Icons.monitor_weight_outlined),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          if (_recommendedSize.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFF4D6D).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFF4D6D).withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  Text(
                    "WE RECOMMEND",
                    style: GoogleFonts.dmSans(
                      color: const Color(0xFFFF4D6D),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Size $_recommendedSize",
                    style: GoogleFonts.syne(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _fitNote,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4D6D),
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 0,
            ),
            onPressed: _calculateSize,
            child: Text(
              _recommendedSize.isEmpty ? "Calculate My Size" : "Recalculate",
              style: GoogleFonts.syne(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
      prefixIcon: Icon(icon, color: Colors.white24, size: 20),
      filled: true,
      fillColor: const Color(0xFF0F0F14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.white10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFFF4D6D)),
      ),
    );
  }
}