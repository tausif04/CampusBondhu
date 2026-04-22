import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusbondhu/core/constants/app_constants.dart';
import 'package:campusbondhu/features/study_buddy/data/models/study_group_model.dart';

final studyGroupServiceProvider =
    Provider<StudyGroupService>((ref) => StudyGroupService());

class StudyGroupService {
  final _db = FirebaseFirestore.instance;
  CollectionReference get _groups =>
      _db.collection(AppConstants.studyGroupsCollection);
  CollectionReference get _messages =>
      _db.collection(AppConstants.messagesCollection);

  // Stream all groups
  Stream<List<StudyGroupModel>> getGroups() {
    return _groups
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(StudyGroupModel.fromFirestore).toList());
  }

  // Stream groups for a user
  Stream<List<StudyGroupModel>> getUserGroups(String userId) {
    return _groups
        .where('members', arrayContains: userId)
        .snapshots()
        .map((s) => s.docs.map(StudyGroupModel.fromFirestore).toList());
  }

  // Create group
  Future<String> createGroup(StudyGroupModel group) async {
    final ref = await _groups.add(group.toFirestore());
    return ref.id;
  }

  // Join group
  Future<void> joinGroup(String groupId, String userId) async {
    await _groups.doc(groupId).update({
      'members': FieldValue.arrayUnion([userId]),
      'memberCount': FieldValue.increment(1),
    });
  }

  // Leave group
  Future<void> leaveGroup(String groupId, String userId) async {
    await _groups.doc(groupId).update({
      'members': FieldValue.arrayRemove([userId]),
      'memberCount': FieldValue.increment(-1),
    });
  }

  // Check membership
  Future<bool> isMember(String groupId, String userId) async {
    final doc = await _groups.doc(groupId).get();
    if (!doc.exists) return false;
    final data = doc.data() as Map<String, dynamic>;
    final members = List<String>.from(data['members'] ?? []);
    return members.contains(userId);
  }

  // Send message — uses serverTimestamp so ordering is always accurate
  Future<void> sendMessage(MessageModel message) async {
    final batch = _db.batch();

    final msgRef = _messages.doc();
    // Use server timestamp for reliable ordering across devices/timezones
    final msgData = {
      'groupId': message.groupId,
      'senderId': message.senderId,
      'senderName': message.senderName,
      'senderImage': message.senderImage,
      'text': message.text,
      'timestamp': FieldValue.serverTimestamp(), // ← server time, not device
    };
    batch.set(msgRef, msgData);

    batch.update(_groups.doc(message.groupId), {
      'lastMessage': message.text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // Stream messages — ordered by timestamp (requires composite index)
  // Index needed: groupId ASC + timestamp ASC
  // Create at: Firebase Console → Firestore → Indexes → Add composite index
  Stream<List<MessageModel>> getMessages(String groupId) {
    return _messages
        .where('groupId', isEqualTo: groupId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((s) => s.docs.map(MessageModel.fromFirestore).toList());
  }

  // Get single group
  Future<StudyGroupModel?> getGroup(String id) async {
    final doc = await _groups.doc(id).get();
    return doc.exists ? StudyGroupModel.fromFirestore(doc) : null;
  }
}
