import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/study_buddy_provider.dart';

class StudySearchBar extends ConsumerWidget {
  const StudySearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search by subject or name",
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onChanged: (value) {
        ref.read(studyBuddyProvider.notifier).setSearch(value);
      },
    );
  }
}
