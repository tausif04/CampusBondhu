import 'package:flutter_riverpod/flutter_riverpod.dart';

final eventProvider = Provider<EventModel>((ref) {
  return EventModel(
    title: "Spring Festival 2026",
    description: "Join us for music, food, and fun at the main quad",
    isLive: true,
  );
});

class EventModel {
  final String title;
  final String description;
  final bool isLive;

  EventModel({
    required this.title,
    required this.description,
    required this.isLive,
  });
}
