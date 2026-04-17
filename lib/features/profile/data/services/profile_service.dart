import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class ProfileService {
  // 🔹 Get user
  Future<UserModel> getUser() async {
    final prefs = await SharedPreferences.getInstance();

    return UserModel(
      name: prefs.getString('name') ?? "No Name",
      email: prefs.getString('email') ?? "",
      university: prefs.getString('university') ?? "",
      department: prefs.getString('department') ?? "",
      year: prefs.getString('year') ?? "",
      bio: prefs.getString('bio') ?? "Add your bio",
      interests: prefs.getStringList('interests') ?? [],
      skills: prefs.getStringList('skills') ?? [],
      profileImage: prefs.getString('profileImage'),
    );
  }

  // 🔹 Save user
  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('name', user.name);
    await prefs.setString('email', user.email);
    await prefs.setString('university', user.university);
    await prefs.setString('department', user.department);
    await prefs.setString('year', user.year);
    await prefs.setString('bio', user.bio);
    await prefs.setStringList('interests', user.interests);
    await prefs.setStringList('skills', user.skills);

    if (user.profileImage != null) {
      await prefs.setString('profileImage', user.profileImage!);
    }
  }
}
