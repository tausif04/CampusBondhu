import 'package:flutter/material.dart';

// 👇 import your widgets
import '../widgets/profile_header.dart';
import '../widgets/info_card.dart';
import '../widgets/chip_section.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildUI());
  }

  // 🔥 Main Layout
  Widget _buildUI() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 👤 NEW HEADER
            const ProfileHeader(
              name: "Tausif Bin Mozid",
              subtitle: "CSE • DU • 3rd Year",
            ),

            _buildBody(),
          ],
        ),
      ),
    );
  }

  // 📦 Body Section
  Widget _buildBody() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: ListView(
          children: [
            _sectionTitle("Bio"),
            const InfoCard(
              text:
                  "AI & Flutter developer passionate about solving real-world problems.",
            ),

            const SizedBox(height: 15),

            const ChipSection(
              title: "Interests",
              items: ["AI", "Flutter", "Photography"],
            ),

            const SizedBox(height: 15),

            const ChipSection(
              title: "Skills",
              items: ["Python", "Django", "Flutter"],
            ),

            const SizedBox(height: 25),

            _editButton(),
          ],
        ),
      ),
    );
  }

  // 🔹 Section Title
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  // 🚀 Edit Button
  Widget _editButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4F46E5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          Navigator.pushNamed(context, '/edit-profile'); //  connect
        },
        child: const Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
