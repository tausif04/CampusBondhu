import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusbondhu/features/auth/data/datasources/auth_service.dart';
import 'package:campusbondhu/features/auth/data/models/user_model.dart';

// Firebase auth state stream
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Current user model
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateProvider);
  if (authState.valueOrNull == null) return null;
  final service = ref.read(authServiceProvider);
  return service.getCurrentUser();
});

// Auth notifier for login/register actions
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthService _service;

  AuthNotifier(this._service) : super(const AsyncValue.data(null));

  Future<void> login({
    required String emailOrUsername,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() =>
        _service.login(emailOrUsername: emailOrUsername, password: password));
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String username,
    required String institution,
    required String department,
    required String yearSemester,
    required List<String> interests,
    String? phone,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.register(
          email: email,
          password: password,
          name: name,
          username: username,
          institution: institution,
          department: department,
          yearSemester: yearSemester,
          interests: interests,
          phone: phone,
        ));
  }

  // Register with optional profile image
  Future<void> registerWithImage({
    required String email,
    required String password,
    required String name,
    required String username,
    required String institution,
    required String department,
    required String yearSemester,
    required List<String> interests,
    String? phone,
    dynamic profileImage,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.register(
          email: email,
          password: password,
          name: name,
          username: username,
          institution: institution,
          department: department,
          yearSemester: yearSemester,
          interests: interests,
          phone: phone,
          profileImage: profileImage,
        ));
  }

  Future<void> logout() async {
    await _service.logout();
    state = const AsyncValue.data(null);
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});
