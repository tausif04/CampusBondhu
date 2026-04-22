import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:campusbondhu/features/auth/presentation/pages/login_page.dart';
import 'package:campusbondhu/features/auth/presentation/pages/register_page.dart';
import 'package:campusbondhu/features/auth/presentation/providers/auth_provider.dart';
import 'package:campusbondhu/features/home/presentation/pages/home_page.dart';
import 'package:campusbondhu/features/study_buddy/presentation/pages/study_buddy_page.dart';
import 'package:campusbondhu/features/study_buddy/presentation/pages/study_group_chat_page.dart';
import 'package:campusbondhu/features/study_buddy/presentation/pages/create_group_page.dart';
import 'package:campusbondhu/features/events/presentation/pages/events_page.dart';
import 'package:campusbondhu/features/events/presentation/pages/event_detail_page.dart';
import 'package:campusbondhu/features/events/presentation/pages/create_event_page.dart';
import 'package:campusbondhu/features/profile/presentation/pages/profile_page.dart';
import 'package:campusbondhu/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:campusbondhu/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:campusbondhu/features/admin/presentation/pages/admin_events_page.dart';
import 'package:campusbondhu/features/admin/presentation/pages/admin_users_page.dart';
import 'package:campusbondhu/config/shell_scaffold.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const studyBuddy = '/study-buddy';
  static const studyGroupChat = '/study-buddy/chat/:groupId';
  static const createGroup = '/study-buddy/create';
  static const events = '/events';
  static const eventDetail = '/events/:eventId';
  static const createEvent = '/events/create';
  static const profile = '/profile';
  static const editProfile = '/profile/edit';
  static const adminDashboard = '/admin';
  static const adminEvents = '/admin/events';
  static const adminUsers = '/admin/users';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final currentUser = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isLoginPage = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      if (!isLoggedIn && !isLoginPage) return AppRoutes.login;
      if (isLoggedIn && isLoginPage) return AppRoutes.home;

      // Admin route guard — only isAdmin users may access /admin/*
      if (state.matchedLocation.startsWith('/admin')) {
        final user = currentUser.valueOrNull;
        if (user == null || !user.isAdmin) return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (ctx, state) => _fadeTransition(state, const LoginPage()),
      ),
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (ctx, state) => _fadeTransition(state, const RegisterPage()),
      ),
      ShellRoute(
        builder: (ctx, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (ctx, state) => _fadeTransition(state, const HomePage()),
          ),
          GoRoute(
            path: AppRoutes.studyBuddy,
            pageBuilder: (ctx, state) => _fadeTransition(state, const StudyBuddyPage()),
            routes: [
              GoRoute(
                path: 'chat/:groupId',
                builder: (ctx, state) => StudyGroupChatPage(
                  groupId: state.pathParameters['groupId']!,
                ),
              ),
              GoRoute(
                path: 'create',
                builder: (ctx, state) => const CreateGroupPage(),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.events,
            pageBuilder: (ctx, state) => _fadeTransition(state, const EventsPage()),
            routes: [
              GoRoute(
                path: ':eventId',
                builder: (ctx, state) => EventDetailPage(
                  eventId: state.pathParameters['eventId']!,
                ),
              ),
              GoRoute(
                path: 'create',
                builder: (ctx, state) => const CreateEventPage(),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (ctx, state) => _fadeTransition(state, const ProfilePage()),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (ctx, state) => const EditProfilePage(),
              ),
            ],
          ),
        ],
      ),
      // Admin routes (separate shell)
      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (ctx, state) => const AdminDashboardPage(),
        routes: [
          GoRoute(
            path: 'events',
            builder: (ctx, state) => const AdminEventsPage(),
          ),
          GoRoute(
            path: 'users',
            builder: (ctx, state) => const AdminUsersPage(),
          ),
        ],
      ),
    ],
  );
});

CustomTransitionPage _fadeTransition(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (ctx, animation, secondary, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}
