import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusbondhu/features/study_buddy/data/datasources/study_group_service.dart';
import 'package:campusbondhu/features/study_buddy/data/models/study_group_model.dart';

// All groups stream
final allGroupsProvider = StreamProvider<List<StudyGroupModel>>((ref) {
  return ref.watch(studyGroupServiceProvider).getGroups();
});

// Messages stream for a group
final groupMessagesProvider =
    StreamProvider.family<List<MessageModel>, String>((ref, groupId) {
  return ref.watch(studyGroupServiceProvider).getMessages(groupId);
});

// Filter state
class GroupFilter {
  final String searchQuery;
  final List<String> selectedInterests;
  final String? department;

  const GroupFilter({
    this.searchQuery = '',
    this.selectedInterests = const [],
    this.department,
  });

  GroupFilter copyWith({
    String? searchQuery,
    List<String>? selectedInterests,
    String? department,
  }) {
    return GroupFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedInterests: selectedInterests ?? this.selectedInterests,
      department: department ?? this.department,
    );
  }
}

final groupFilterProvider = StateProvider<GroupFilter>((ref) => const GroupFilter());

// Filtered groups
final filteredGroupsProvider = Provider<AsyncValue<List<StudyGroupModel>>>((ref) {
  final groupsAsync = ref.watch(allGroupsProvider);
  final filter = ref.watch(groupFilterProvider);

  return groupsAsync.whenData((groups) {
    var filtered = groups;

    if (filter.searchQuery.isNotEmpty) {
      final q = filter.searchQuery.toLowerCase();
      filtered = filtered
          .where((g) =>
              g.name.toLowerCase().contains(q) ||
              g.subject.toLowerCase().contains(q))
          .toList();
    }

    if (filter.selectedInterests.isNotEmpty) {
      filtered = filtered
          .where((g) => g.tags.any((t) => filter.selectedInterests.contains(t)))
          .toList();
    }

    return filtered;
  });
});

// Group creation notifier
class GroupCreationNotifier extends StateNotifier<AsyncValue<String?>> {
  final StudyGroupService _service;

  GroupCreationNotifier(this._service) : super(const AsyncValue.data(null));

  Future<void> create(StudyGroupModel group) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.createGroup(group));
  }
}

final groupCreationProvider =
    StateNotifierProvider<GroupCreationNotifier, AsyncValue<String?>>((ref) {
  return GroupCreationNotifier(ref.read(studyGroupServiceProvider));
});

// Send message notifier
class SendMessageNotifier extends StateNotifier<AsyncValue<void>> {
  final StudyGroupService _service;

  SendMessageNotifier(this._service) : super(const AsyncValue.data(null));

  Future<void> send(MessageModel message) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.sendMessage(message));
  }
}

final sendMessageProvider =
    StateNotifierProvider<SendMessageNotifier, AsyncValue<void>>((ref) {
  return SendMessageNotifier(ref.read(studyGroupServiceProvider));
});
