class UserModel {
  final String name;
  final String email;
  final String university;
  final String department;
  final String year;
  final String bio;
  final List<String> interests;
  final List<String> skills;
  final String? profileImage;

  UserModel({
    required this.name,
    required this.email,
    required this.university,
    required this.department,
    required this.year,
    required this.bio,
    required this.interests,
    required this.skills,
    this.profileImage,
  });

  // 🔹 Convert Firestore → Model
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      university: map['university'] ?? '',
      department: map['department'] ?? '',
      year: map['year'] ?? '',
      bio: map['bio'] ?? '',
      interests: List<String>.from(map['interests'] ?? []),
      skills: List<String>.from(map['skills'] ?? []),
      profileImage: map['profileImage'],
    );
  }

  // 🔹 Convert Model → Firestore
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "email": email,
      "university": university,
      "department": department,
      "year": year,
      "bio": bio,
      "interests": interests,
      "skills": skills,
      "profileImage": profileImage,
    };
  }
}
