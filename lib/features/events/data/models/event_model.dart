import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class EventModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime dateTime;
  final String organizerName;
  final String organizerId;
  final String status; // pending / approved / rejected
  final List<String> tags;
  final String? imageUrl;
  final int registrationCount;
  final DateTime createdAt;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.dateTime,
    required this.organizerName,
    required this.organizerId,
    required this.status,
    this.tags = const [],
    this.imageUrl,
    this.registrationCount = 0,
    required this.createdAt,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      location: d['location'] ?? '',
      dateTime: (d['dateTime'] as Timestamp).toDate(),
      organizerName: d['organizerName'] ?? '',
      organizerId: d['organizerId'] ?? '',
      status: d['status'] ?? 'pending',
      tags: List<String>.from(d['tags'] ?? []),
      imageUrl: d['imageUrl'],
      registrationCount: d['registrationCount'] ?? 0,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'title': title,
    'description': description,
    'location': location,
    'dateTime': Timestamp.fromDate(dateTime),
    'organizerName': organizerName,
    'organizerId': organizerId,
    'status': status,
    'tags': tags,
    'imageUrl': imageUrl,
    'registrationCount': registrationCount,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  EventModel copyWith({String? status, int? registrationCount}) {
    return EventModel(
      id: id, title: title, description: description, location: location,
      dateTime: dateTime, organizerName: organizerName, organizerId: organizerId,
      status: status ?? this.status, tags: tags, imageUrl: imageUrl,
      registrationCount: registrationCount ?? this.registrationCount,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, title, status];
}
