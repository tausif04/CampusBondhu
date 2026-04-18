import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/study_buddy_provider.dart';

class FilterSection extends ConsumerWidget {
  const FilterSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyBuddyProvider);
    final notifier = ref.read(studyBuddyProvider.notifier);

    Widget chip(String label, String? selected, Function(String?) onTap) {
      final isSelected = selected == label;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (_) => onTap(isSelected ? null : label),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip("CSE", state.department, notifier.setDepartment),
          chip("EEE", state.department, notifier.setDepartment),
          chip("BBA", state.department, notifier.setDepartment),
          const SizedBox(width: 10),
          chip("1st", state.year, notifier.setYear),
          chip("2nd", state.year, notifier.setYear),
          chip("3rd", state.year, notifier.setYear),
          const SizedBox(width: 10),
          chip("Morning", state.availability, notifier.setAvailability),
          chip("Evening", state.availability, notifier.setAvailability),
        ],
      ),
    );
  }
}
