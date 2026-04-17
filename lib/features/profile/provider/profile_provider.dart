import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🔹 User State Model
class ProfileState {
  final String name;
  final String university;
  final String department;
  final String year;
  final String bio;
  final List<String> interests;
  final List<String> skills;
  final bool isLoading;

  ProfileState({
    this.name = "",
    this.university = "",
    this.department = "",
    this.year = "",
    this.bio = "",
    this.interests = const [],
    this.skills = const [],
    this.isLoading = true,
  });

  ProfileState copyWith({
    String? name,
    String? university,
    String? department,
    String? year,
    String? bio,
    List<String>? interests,
    List<String>? skills,
    bool? isLoading,
  }) {
    return ProfileState(
      name: name ?? this.name,
      university: university ?? this.university,
      department: department ?? this.department,
      year: year ?? this.year,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      skills: skills ?? this.skills,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/////////////////////////////////////////////////////////

// 🔥 Provider
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>(
  (ref) => ProfileNotifier(),
);

/////////////////////////////////////////////////////////

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(ProfileState()) {
    loadUser();
  }

  // 🔹 Load user data
  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();

    state = state.copyWith(
      name: prefs.getString('name') ?? "No Name",
      university: prefs.getString('university') ?? "",
      department: prefs.getString('department') ?? "",
      year: prefs.getString('year') ?? "",
      bio: prefs.getString('bio') ?? "Add your bio",
      interests: prefs.getStringList('interests') ?? ["AI"],
      skills: prefs.getStringList('skills') ?? ["Flutter"],
      isLoading: false,
    );
  }

  // 🔹 Update user
  Future<void> updateUser({
    required String name,
    required String university,
    required String department,
    required String year,
    required String bio,
    required List<String> interests,
    required List<String> skills,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('name', name);
    await prefs.setString('university', university);
    await prefs.setString('department', department);
    await prefs.setString('year', year);
    await prefs.setString('bio', bio);
    await prefs.setStringList('interests', interests);
    await prefs.setStringList('skills', skills);

    // 🔥 update state instantly
    state = state.copyWith(
      name: name,
      university: university,
      department: department,
      year: year,
      bio: bio,
      interests: interests,
      skills: skills,
    );
  }
}
