import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:campus_bondhu/core/widgets/main_scaffold.dart';
import 'package:campus_bondhu/features/auth/presentation/login_page.dart';
import 'package:campus_bondhu/features/auth/presentation/register_page.dart';
import 'package:campus_bondhu/features/home/presentation/home_page.dart';
import 'package:campus_bondhu/features/profile/presentation/pages/profile_page.dart';
import 'package:campus_bondhu/features/auth/provider/auth_provider.dart';
import 'package:campus_bondhu/features/study_buddy/presentation/pages/study_buddy_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',

    // ✅ THIS WORKS PERFECTLY
    refreshListenable: auth,

    redirect: (context, state) {
      final loggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!auth.isLoggedIn && !loggingIn) return '/login';

      if (auth.isLoggedIn && loggingIn) return '/';

      return null;
    },

    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),

      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomePage()),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),

          GoRoute(
            path: '/study-buddy',
            builder: (context, state) => const StudyBuddyPage(),
          ),
        ],
      ),
    ],
  );
});
