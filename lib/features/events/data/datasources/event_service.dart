import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusbondhu/core/constants/app_constants.dart';
import 'package:campusbondhu/features/events/data/models/event_model.dart';

final eventServiceProvider = Provider<EventService>((ref) => EventService());

class EventService {
  final _db = FirebaseFirestore.instance;
  CollectionReference get _col => _db.collection(AppConstants.eventsCollection);

  // Get approved events stream
  Stream<List<EventModel>> getApprovedEvents() {
    return _col
        .where('status', isEqualTo: AppConstants.statusApproved)
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((s) => s.docs.map(EventModel.fromFirestore).toList());
  }

  // Get pending events (admin only)
  Stream<List<EventModel>> getPendingEvents() {
    return _col
        .where('status', isEqualTo: AppConstants.statusPending)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(EventModel.fromFirestore).toList());
  }

  // Get all events (admin)
  Stream<List<EventModel>> getAllEvents() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(EventModel.fromFirestore).toList());
  }

  // Get single event (future)
  Future<EventModel?> getEvent(String id) async {
    final doc = await _col.doc(id).get();
    return doc.exists ? EventModel.fromFirestore(doc) : null;
  }

  // Get single event as real-time stream
  Stream<EventModel?> getEventById(String id) {
    return _col.doc(id).snapshots().map(
          (doc) => doc.exists ? EventModel.fromFirestore(doc) : null,
        );
  }

  // Create event (pending by default)
  Future<String> createEvent(EventModel event) async {
    final ref = await _col.add(event.toFirestore());
    return ref.id;
  }

  // Update event status (admin)
  Future<void> updateStatus(String id, String status) async {
    await _col.doc(id).update({'status': status});
  }

  // Register for event
  Future<void> registerForEvent(String userId, String eventId) async {
    final batch = _db.batch();

    final regRef = _db
        .collection(AppConstants.registrationsCollection)
        .doc('${userId}_$eventId');
    batch.set(regRef, {
      'userId': userId,
      'eventId': eventId,
      'registeredAt': FieldValue.serverTimestamp(),
    });

    final eventRef = _col.doc(eventId);
    batch.update(eventRef, {
      'registrationCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  // Check if user is registered
  Future<bool> isRegistered(String userId, String eventId) async {
    final doc = await _db
        .collection(AppConstants.registrationsCollection)
        .doc('${userId}_$eventId')
        .get();
    return doc.exists;
  }

  // Unregister
  Future<void> unregister(String userId, String eventId) async {
    final batch = _db.batch();
    batch.delete(_db
        .collection(AppConstants.registrationsCollection)
        .doc('${userId}_$eventId'));
    batch.update(_col.doc(eventId), {
      'registrationCount': FieldValue.increment(-1),
    });
    await batch.commit();
  }
}
