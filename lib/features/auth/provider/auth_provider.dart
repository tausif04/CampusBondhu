import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthNotifier extends ChangeNotifier {
  bool isLoggedIn = false;

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (email.isNotEmpty && password.length >= 6) {
      isLoggedIn = true;
      notifyListeners(); // 🔥 triggers router
      return true;
    }
    return false;
  }

  Future<bool> register(
    String email,
    String password,
    String name,
    String university,
    String department,
    String year,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (email.isNotEmpty && password.length >= 6) {
      isLoggedIn = true;
      notifyListeners(); // 🔥 triggers router
      return true;
    }
    return false;
  }

  void logout() {
    isLoggedIn = false;
    notifyListeners();
  }
}

final authProvider = ChangeNotifierProvider<AuthNotifier>((ref) {
  return AuthNotifier();
});
