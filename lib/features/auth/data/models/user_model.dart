import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String username;
  final String email;
  final String? phone;
  final String? profileImage;
  final String institution;
  final String department;
  final String yearSemester;
  final List<String> interests;
  final String? bio;
  final List<String> hobbies;
  final List<String> projects;
  final List<String> research;
  final bool isAdmin;
  final bool isSuspended;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.phone,
    this.profileImage,
    required this.institution,
    required this.department,
    required this.yearSemester,
    required this.interests,
    this.bio,
    this.hobbies = const [],
    this.projects = const [],
    this.research = const [],
    this.isAdmin = false,
    this.isSuspended = false,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      profileImage: data['profileImage'],
      institution: data['institution'] ?? '',
      department: data['department'] ?? '',
      yearSemester: data['yearSemester'] ?? '',
      interests: List<String>.from(data['interests'] ?? []),
      bio: data['bio'],
      hobbies: List<String>.from(data['hobbies'] ?? []),
      projects: List<String>.from(data['projects'] ?? []),
      research: List<String>.from(data['research'] ?? []),
      isAdmin: data['isAdmin'] ?? false,
      isSuspended: data['isSuspended'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'username': username,
    'email': email,
    'phone': phone,
    'profileImage': profileImage,
    'institution': institution,
    'department': department,
    'yearSemester': yearSemester,
    'interests': interests,
    'bio': bio,
    'hobbies': hobbies,
    'projects': projects,
    'research': research,
    'isAdmin': isAdmin,
    'isSuspended': isSuspended,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  UserModel copyWith({
    String? name,
    String? username,
    String? phone,
    String? profileImage,
    String? institution,
    String? department,
    String? yearSemester,
    List<String>? interests,
    String? bio,
    List<String>? hobbies,
    List<String>? projects,
    List<String>? research,
    bool? isAdmin,
    bool? isSuspended,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      institution: institution ?? this.institution,
      department: department ?? this.department,
      yearSemester: yearSemester ?? this.yearSemester,
      interests: interests ?? this.interests,
      bio: bio ?? this.bio,
      hobbies: hobbies ?? this.hobbies,
      projects: projects ?? this.projects,
      research: research ?? this.research,
      isAdmin: isAdmin ?? this.isAdmin,
      isSuspended: isSuspended ?? this.isSuspended,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, username, email];
}
