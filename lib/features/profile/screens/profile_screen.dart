import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/firebase_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showEditProfileDialog(
    BuildContext context,
    String currentName,
    String currentPhone,
  ) {
    final nameController = TextEditingController(text: currentName);
    final phoneController = TextEditingController(text: currentPhone);
    final firebaseService = FirebaseService();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E26),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Edit Profile",
            style: GoogleFonts.syne(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Name",
                  labelStyle: const TextStyle(color: Colors.white54),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFF4D6D)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Phone",
                  labelStyle: const TextStyle(color: Colors.white54),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFF4D6D)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4D6D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                await firebaseService.updateProfile(
                  name: nameController.text.trim(),
                  phone: phoneController.text.trim(),
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.syne(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: firebaseService.getUserProfileStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF4D6D)),
            );
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Center(
              child: Text(
                "Error fetching profile",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final name = userData['name'] ?? 'Add your name';
          final email =
              userData['email'] ??
              firebaseService.currentUserUid ??
              'Add email';
          final phone = userData['phone'] ?? 'Add your phone';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E26),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFF4D6D),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white54,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildProfileItem(Icons.person_outline, "Name", name),
              const SizedBox(height: 16),
              _buildProfileItem(Icons.email_outlined, "Email", email),
              const SizedBox(height: 16),
              _buildProfileItem(Icons.phone_outlined, "Phone", phone),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E1E26),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: const BorderSide(color: Color(0xFFFF4D6D)),
                  ),
                ),
                onPressed: () => _showEditProfileDialog(context, name, phone),
                icon: const Icon(Icons.edit, color: Color(0xFFFF4D6D)),
                label: Text(
                  "Edit Profile",
                  style: GoogleFonts.syne(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E26),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF4D6D)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.dmSans(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.syne(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
