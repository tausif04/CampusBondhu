// FILE: firebase_options.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// HOW TO REPLACE THIS WITH YOUR REAL FIREBASE PROJECT
// ─────────────────────────────────────────────────────────────────────────────
// 1. Go to https://console.firebase.google.com  →  your project
// 2. Project Settings → General → Your apps → Add app → Web
// 3. Copy the firebaseConfig values and paste them below, OR run:
//      dart pub global activate flutterfire_cli
//      flutterfire configure --project=YOUR_PROJECT_ID
//    which will auto-generate this file for every platform.
//
// Until then, the DEMO values below let the app compile and show the UI,
// but all Firebase calls (login, Firestore, Storage) will fail at runtime
// because the project ID is a placeholder.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        return web; // fallback for linux/windows desktop
    }
  }

  // ── REPLACE every value below with your real Firebase config ──────────────

  static const FirebaseOptions web = FirebaseOptions(
      apiKey: "AIzaSyDInBav8E2beakYt_tqPuLjFqKA3OLpcR8",
      authDomain: "campusbondhu-a2d5b.firebaseapp.com",
      projectId: "campusbondhu-a2d5b",
      storageBucket: "campusbondhu-a2d5b.firebasestorage.app",
      messagingSenderId: "8036376123",
      appId: "1:8036376123:web:4bbbf83a1f8233b274c61e");

  static const FirebaseOptions android = FirebaseOptions(
      apiKey: "AIzaSyDInBav8E2beakYt_tqPuLjFqKA3OLpcR8",
      authDomain: "campusbondhu-a2d5b.firebaseapp.com",
      projectId: "campusbondhu-a2d5b",
      storageBucket: "campusbondhu-a2d5b.firebasestorage.app",
      messagingSenderId: "8036376123",
      appId: "1:8036376123:web:4bbbf83a1f8233b274c61e");

  static const FirebaseOptions ios = FirebaseOptions(
      apiKey: "AIzaSyDInBav8E2beakYt_tqPuLjFqKA3OLpcR8",
      authDomain: "campusbondhu-a2d5b.firebaseapp.com",
      projectId: "campusbondhu-a2d5b",
      storageBucket: "campusbondhu-a2d5b.firebasestorage.app",
      messagingSenderId: "8036376123",
      appId: "1:8036376123:web:4bbbf83a1f8233b274c61e");

  static const FirebaseOptions macos = FirebaseOptions(
      apiKey: "AIzaSyDInBav8E2beakYt_tqPuLjFqKA3OLpcR8",
      authDomain: "campusbondhu-a2d5b.firebaseapp.com",
      projectId: "campusbondhu-a2d5b",
      storageBucket: "campusbondhu-a2d5b.firebasestorage.app",
      messagingSenderId: "8036376123",
      appId: "1:8036376123:web:4bbbf83a1f8233b274c61e");
}
