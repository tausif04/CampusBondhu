import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class StudyGroupModel extends Equatable {
  final String id;
  final String name;
  final String subject;
  final String description;
  final String createdById;
  final String createdByName;
  final List<String> members;
  final List<String> tags;
  final int memberCount;
  final DateTime createdAt;
  final String? lastMessage;
  final DateTime? lastMessageTime;

  const StudyGroupModel({
    required this.id,
    required this.name,
    required this.subject,
    required this.description,
    required this.createdById,
    required this.createdByName,
    required this.members,
    this.tags = const [],
    this.memberCount = 1,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageTime,
  });

  factory StudyGroupModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return StudyGroupModel(
      id: doc.id,
      name: d['name'] ?? '',
      subject: d['subject'] ?? '',
      description: d['description'] ?? '',
      createdById: d['createdById'] ?? '',
      createdByName: d['createdByName'] ?? '',
      members: List<String>.from(d['members'] ?? []),
      tags: List<String>.from(d['tags'] ?? []),
      memberCount: d['memberCount'] ?? 1,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessage: d['lastMessage'],
      lastMessageTime: (d['lastMessageTime'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'subject': subject,
    'description': description,
    'createdById': createdById,
    'createdByName': createdByName,
    'members': members,
    'tags': tags,
    'memberCount': memberCount,
    'createdAt': Timestamp.fromDate(createdAt),
    'lastMessage': lastMessage,
    'lastMessageTime': lastMessageTime != null ? Timestamp.fromDate(lastMessageTime!) : null,
  };

  @override
  List<Object?> get props => [id, name, subject];
}

class MessageModel extends Equatable {
  final String id;
  final String groupId;
  final String senderId;
  final String senderName;
  final String? senderImage;
  final String text;
  final DateTime timestamp;

  const MessageModel({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.senderName,
    this.senderImage,
    required this.text,
    required this.timestamp,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      groupId: d['groupId'] ?? '',
      senderId: d['senderId'] ?? '',
      senderName: d['senderName'] ?? '',
      senderImage: d['senderImage'],
      text: d['text'] ?? '',
      timestamp: (d['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'groupId': groupId,
    'senderId': senderId,
    'senderName': senderName,
    'senderImage': senderImage,
    'text': text,
    'timestamp': Timestamp.fromDate(timestamp),
  };

  @override
  List<Object?> get props => [id, text, timestamp];
}
