import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/study_buddy_provider.dart';
import '../widgets/buddy_card.dart';
import '../widgets/filter_section.dart';
import '../widgets/search_bar.dart';

class StudyBuddyPage extends ConsumerWidget {
  const StudyBuddyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(studyBuddyProvider.notifier);
    final buddies = notifier.filtered;

    return Scaffold(
      appBar: AppBar(title: const Text("Study Buddy")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const StudySearchBar(),
            const SizedBox(height: 12),
            const FilterSection(),
            const SizedBox(height: 12),
            Expanded(
              child: buddies.isEmpty
                  ? const Center(child: Text("No study buddies found"))
                  : GridView.builder(
                      itemCount: buddies.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                      itemBuilder: (_, i) => BuddyCard(buddy: buddies[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
