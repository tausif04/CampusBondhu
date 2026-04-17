import 'package:flutter/material.dart';

class ChipSection extends StatelessWidget {
  final String title;
  final List<String> items;

  const ChipSection({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        Wrap(
          spacing: 8,
          children: items.map((item) {
            return Chip(
              label: Text(item),
              backgroundColor: const Color(0xFFE0E7FF),
            );
          }).toList(),
        ),
      ],
    );
  }
}
