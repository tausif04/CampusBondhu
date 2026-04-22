import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusbondhu/features/events/data/datasources/event_service.dart';
import 'package:campusbondhu/features/events/data/models/event_model.dart';

// Stream of approved events
final approvedEventsProvider = StreamProvider<List<EventModel>>((ref) {
  return ref.watch(eventServiceProvider).getApprovedEvents();
});

// Single event by ID (real-time)
final singleEventProvider =
    StreamProvider.family<EventModel?, String>((ref, eventId) {
  return ref.watch(eventServiceProvider).getEventById(eventId);
});

// Stream of pending events (admin)
final pendingEventsProvider = StreamProvider<List<EventModel>>((ref) {
  return ref.watch(eventServiceProvider).getPendingEvents();
});

// All events (admin)
final allEventsProvider = StreamProvider<List<EventModel>>((ref) {
  return ref.watch(eventServiceProvider).getAllEvents();
});

// Filter state
class EventFilter {
  final String searchQuery;
  final List<String> selectedTags;

  const EventFilter({this.searchQuery = '', this.selectedTags = const []});

  EventFilter copyWith({String? searchQuery, List<String>? selectedTags}) {
    return EventFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTags: selectedTags ?? this.selectedTags,
    );
  }
}

final eventFilterProvider = StateProvider<EventFilter>((ref) => const EventFilter());

// Filtered events
final filteredEventsProvider = Provider<AsyncValue<List<EventModel>>>((ref) {
  final eventsAsync = ref.watch(approvedEventsProvider);
  final filter = ref.watch(eventFilterProvider);

  return eventsAsync.whenData((events) {
    var filtered = events;

    if (filter.searchQuery.isNotEmpty) {
      final q = filter.searchQuery.toLowerCase();
      filtered = filtered
          .where((e) =>
              e.title.toLowerCase().contains(q) ||
              e.description.toLowerCase().contains(q) ||
              e.location.toLowerCase().contains(q))
          .toList();
    }

    if (filter.selectedTags.isNotEmpty) {
      filtered = filtered
          .where((e) => e.tags.any((t) => filter.selectedTags.contains(t)))
          .toList();
    }

    return filtered;
  });
});

// Event creation notifier
class EventCreationNotifier extends StateNotifier<AsyncValue<String?>> {
  final EventService _service;

  EventCreationNotifier(this._service) : super(const AsyncValue.data(null));

  Future<void> create(EventModel event) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.createEvent(event));
  }
}

final eventCreationProvider =
    StateNotifierProvider<EventCreationNotifier, AsyncValue<String?>>((ref) {
  return EventCreationNotifier(ref.read(eventServiceProvider));
});

// Registration state
final registrationProvider =
    FutureProvider.family<bool, ({String userId, String eventId})>((ref, args) {
  return ref.read(eventServiceProvider).isRegistered(args.userId, args.eventId);
});
