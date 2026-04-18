import 'package:flutter/material.dart';
import '../../data/models/buddy_model.dart';

class BuddyCard extends StatelessWidget {
  final Buddy buddy;

  const BuddyCard({super.key, required this.buddy});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    buddy.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text("${buddy.department} • ${buddy.year}"),
            Text("Subjects: ${buddy.subjects.join(', ')}"),
            Text("Availability: ${buddy.availability}"),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: () {
                  debugPrint("Connect with ${buddy.name}");
                },
                child: const Text("Connect"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
