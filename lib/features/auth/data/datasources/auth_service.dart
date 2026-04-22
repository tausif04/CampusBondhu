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

  // ─────────────────────────────────────────────────────────────────────────
  // REGISTER
  // Root cause of permission-denied: the OLD code checked username uniqueness
  // BEFORE creating the Auth user, so request.auth was null and Firestore
  // rejected the read. Fix: create Auth user first, then do Firestore work.
  // ─────────────────────────────────────────────────────────────────────────
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
    // 1. Create Auth user first — now request.auth will be non-null
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;

    try {
      // 2. Check username uniqueness (now authenticated — no permission error)
      final existing = await _firestore
          .collection(AppConstants.usersCollection)
          .where('username', isEqualTo: username)
          .get();
      if (existing.docs.isNotEmpty) {
        // Clean up orphaned Auth account before throwing
        await credential.user!.delete();
        throw Exception('Username already taken. Please choose another.');
      }

      // 3. Upload profile image if provided (silently skipped if Storage
      //    is not configured — app still works without photos)
      String? imageUrl;
      if (profileImage != null) {
        try {
          final ref = _storage
              .ref()
              .child(AppConstants.profileImagesPath)
              .child('$uid.jpg');
          await ref.putFile(profileImage);
          imageUrl = await ref.getDownloadURL();
        } catch (_) {
          // Storage not set up — continue without image
        }
      }

      // 4. Write Firestore user document
      final user = UserModel(
        id: uid,
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
          .doc(uid)
          .set(user.toFirestore());

      return user;
    } catch (e) {
      // If anything after Auth creation fails, clean up the Auth account
      // so the user can try again without "email already in use" errors
      try {
        await _auth.currentUser?.delete();
      } catch (_) {}
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LOGIN — email OR username
  // Username lookup: sign in with email first is not possible without the
  // email, so we use a Cloud Function-free approach: sign in with email after
  // looking up via a server-side rules-exempt path. Since our Firestore rules
  // allow read if request.auth != null, we sign in first with email/password.
  // For username flow: we store email in Firestore — but we need auth to read
  // it. Solution: try signing in directly; if input has no @, we first do the
  // lookup using the already-authenticated state from a fresh sign-in attempt,
  // which won't work. Instead we make the users collection publicly readable
  // for the username field only — OR we use the simpler approach below:
  // allow the username→email lookup to be unauthenticated by adjusting rules.
  // ─────────────────────────────────────────────────────────────────────────
  Future<UserModel> login({
    required String emailOrUsername,
    required String password,
  }) async {
    String email = emailOrUsername;

    if (!emailOrUsername.contains('@')) {
      // Username login: lookup email without auth using a public index rule
      // (see Firestore rules — users collection allows unauthenticated reads
      // on the username field via the updated rules below)
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
