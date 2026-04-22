import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusbondhu/core/constants/app_constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────
class AppNotification {
  final String id;
  final String userId;
  final String type; // 'message' | 'event_approved' | 'event_rejected' | 'event_upcoming'
  final String title;
  final String body;
  final String? routePath;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.routePath,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      userId: d['userId'] ?? '',
      type: d['type'] ?? '',
      title: d['title'] ?? '',
      body: d['body'] ?? '',
      routePath: d['routePath'],
      isRead: d['isRead'] ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'type': type,
    'title': title,
    'body': body,
    'routePath': routePath,
    'isRead': isRead,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Service
// ─────────────────────────────────────────────────────────────────────────────
final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService());

class NotificationService {
  final _db = FirebaseFirestore.instance;
  CollectionReference get _col =>
      _db.collection(AppConstants.notificationsCollection);

  Stream<List<AppNotification>> getNotifications(String userId) {
    return _col
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map(AppNotification.fromFirestore).toList());
  }

  Stream<int> getUnreadCount(String userId) {
    return _col
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.length);
  }

  Future<void> createNotification(AppNotification n) async {
    await _col.add(n.toFirestore());
  }

  Future<void> markRead(String notifId) async {
    await _col.doc(notifId).update({'isRead': true});
  }

  Future<void> markAllRead(String userId) async {
    final batch = _db.batch();
    final unread = await _col
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> deleteNotification(String notifId) async {
    await _col.doc(notifId).delete();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// New message — notifies all group members except the sender
  Future<void> notifyNewMessage({
    required List<String> memberIds,
    required String senderId,
    required String senderName,
    required String groupName,
    required String groupId,
    String messageText = '',
  }) async {
    for (final uid in memberIds) {
      if (uid == senderId) continue;
      await createNotification(AppNotification(
        id: '',
        userId: uid,
        type: 'message',
        title: 'New message in $groupName',
        body: '$senderName: $messageText',
        routePath: '/study-buddy/chat/$groupId',
        isRead: false,
        createdAt: DateTime.now(),
      ));
    }
  }

  /// Event approved or rejected — notifies organizer
  Future<void> notifyEventStatus({
    required String organizerId,
    required String eventTitle,
    required String eventId,
    required bool approved,
  }) async {
    await createNotification(AppNotification(
      id: '',
      userId: organizerId,
      type: approved ? 'event_approved' : 'event_rejected',
      title: approved ? 'Event Approved! 🎉' : 'Event Rejected',
      body: approved
          ? '"$eventTitle" is now live for everyone to see.'
          : '"$eventTitle" was not approved. You can edit and resubmit.',
      routePath: '/events/$eventId',
      isRead: false,
      createdAt: DateTime.now(),
    ));
  }

  /// Upcoming event reminder — notifies a registered user
  Future<void> notifyEventUpcoming({
    required String userId,
    required String eventTitle,
    required String eventId,
    required String timeLeft,
  }) async {
    await createNotification(AppNotification(
      id: '',
      userId: userId,
      type: 'event_upcoming',
      title: 'Upcoming Event Reminder ⏰',
      body: '"$eventTitle" is $timeLeft away!',
      routePath: '/events/$eventId',
      isRead: false,
      createdAt: DateTime.now(),
    ));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────
final notificationsProvider =
    StreamProvider.family<List<AppNotification>, String>((ref, userId) {
  return ref.watch(notificationServiceProvider).getNotifications(userId);
});

final unreadCountProvider =
    StreamProvider.family<int, String>((ref, userId) {
  return ref.watch(notificationServiceProvider).getUnreadCount(userId);
});
