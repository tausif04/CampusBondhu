import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/home_provider.dart';

class EventCard extends ConsumerWidget {
  const EventCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = ref.watch(eventProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2E3A59),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (event.isLive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "LIVE EVENT",
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            event.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            event.description,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: () {}, child: const Text("View Details")),
        ],
      ),
    );
  }
}
