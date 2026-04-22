import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusbondhu/core/constants/app_constants.dart';
import 'package:campusbondhu/features/auth/data/models/user_model.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register with email & username
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    required String username,
    required String institution,
    required String department,
    required String yearSemester,
    required List<String> interests,
    String? phone,
    List<String> projects = const [],
    List<String> research = const [],
    File? profileImage,
  }) async {
    // Check username uniqueness
    final existing = await _firestore
        .collection(AppConstants.usersCollection)
        .where('username', isEqualTo: username)
        .get();
    if (existing.docs.isNotEmpty) {
      throw Exception('Username already taken. Please choose another.');
    }

    // Create Firebase Auth user
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    String? imageUrl;
    if (profileImage != null) {
      final ref = _storage
          .ref()
          .child(AppConstants.profileImagesPath)
          .child('${credential.user!.uid}.jpg');
      await ref.putFile(profileImage);
      imageUrl = await ref.getDownloadURL();
    }

    final user = UserModel(
      id: credential.user!.uid,
      name: name,
      username: username,
      email: email,
      phone: phone,
      profileImage: imageUrl,
      institution: institution,
      department: department,
      yearSemester: yearSemester,
      interests: interests,
      projects: projects,
      research: research,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.id)
        .set(user.toFirestore());

    return user;
  }

  // Login with email OR username
  Future<UserModel> login({
    required String emailOrUsername,
    required String password,
  }) async {
    String email = emailOrUsername;

    // If it's a username (no @), look up the email
    if (!emailOrUsername.contains('@')) {
      final query = await _firestore
          .collection(AppConstants.usersCollection)
          .where('username', isEqualTo: emailOrUsername)
          .limit(1)
          .get();
      if (query.docs.isEmpty) {
        throw Exception('No account found with this username.');
      }
      email = query.docs.first['email'];
    }

    await _auth.signInWithEmailAndPassword(email: email, password: password);
    return getCurrentUser();
  }

  Future<UserModel> getCurrentUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    return UserModel.fromFirestore(doc);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<UserModel> updateProfile(UserModel user) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.id)
        .update(user.toFirestore());
    return user;
  }

  Future<String> uploadProfileImage(String uid, File image) async {
    final ref = _storage
        .ref()
        .child(AppConstants.profileImagesPath)
        .child('$uid.jpg');
    await ref.putFile(image);
    return ref.getDownloadURL();
  }
}
