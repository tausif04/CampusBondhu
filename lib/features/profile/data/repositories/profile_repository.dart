import '../models/user_model.dart';
import '../services/profile_service.dart';

class ProfileRepository {
  final ProfileService service;

  ProfileRepository(this.service);

  // 🔹 Get user
  Future<UserModel> getUser() async {
    return await service.getUser();
  }

  // 🔹 Update user
  Future<void> updateUser(UserModel user) async {
    await service.saveUser(user);
  }
}
