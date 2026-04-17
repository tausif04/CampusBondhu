import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String subtitle;
  final String? imageUrl;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.subtitle,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.white,
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
            child: imageUrl == null ? const Icon(Icons.person, size: 40) : null,
          ),

          const SizedBox(height: 10),

          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 5),

          Text(subtitle, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
