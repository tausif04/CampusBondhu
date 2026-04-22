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

class _RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  bool _isLoggedIn = false;
  bool _isAdmin = false;

  _RouterNotifier(this._ref) {
    // Listen to auth state changes and notify GoRouter to re-run redirect
    _ref.listen(authStateProvider, (_, next) {
      _isLoggedIn = next.valueOrNull != null;
      notifyListeners();
    });
    _ref.listen(currentUserProvider, (_, next) {
      _isAdmin = next.valueOrNull?.isAdmin ?? false;
      notifyListeners();
    });
  }

  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin => _isAdmin;
}

// The router is created once and cached for the lifetime of the app.
// Using keepAlive: true ensures Riverpod never disposes and recreates it.
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  final router = GoRouter(
    // Start at splash '/' — redirect will immediately send to the right place.
    // On web, GoRouter reads the current browser URL hash on first load, so
    // if the user is at /#/events and reloads, GoRouter sees /events as the
    // initial location and the redirect preserves it.
    initialLocation: AppRoutes.splash,

    // refreshListenable tells GoRouter to re-run redirect when auth changes,
    // WITHOUT creating a new router. This is what keeps the current page
    // intact on reload.
    refreshListenable: notifier,

    redirect: (context, state) {
      final loc = state.matchedLocation;
      final isLoggedIn = notifier.isLoggedIn;
      final isAuthLoading = ref.read(authStateProvider).isLoading;

      // While Firebase is initialising, don't redirect anywhere
      if (isAuthLoading) return null;

      final isAuthPage = loc == AppRoutes.login || loc == AppRoutes.register;
      final isSplash = loc == AppRoutes.splash;

      // Not logged in → force to login (unless already there)
      if (!isLoggedIn && !isAuthPage) return AppRoutes.login;

      // Logged in + on auth page or bare splash → go to home
      if (isLoggedIn && (isAuthPage || isSplash)) return AppRoutes.home;

      // Admin guard
      if (loc.startsWith('/admin') && !notifier.isAdmin) return AppRoutes.home;

      if (state.matchedLocation == '/events/create') {
        return '/events/create';
      }

      // Logged in, valid page → stay exactly where they are
      return null;
    },

    routes: [
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (ctx, state) => _fade(state, const LoginPage()),
      ),
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (ctx, state) => _fade(state, const RegisterPage()),
      ),
      ShellRoute(
        builder: (ctx, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (ctx, state) => _fade(state, const HomePage()),
          ),
          GoRoute(
            path: AppRoutes.studyBuddy,
            pageBuilder: (ctx, state) => _fade(state, const StudyBuddyPage()),
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
            pageBuilder: (ctx, state) => _fade(state, const EventsPage()),
            routes: [
              GoRoute(
                path: 'create',
                builder: (ctx, state) => const CreateEventPage(),
              ),
              GoRoute(
                path: ':eventId',
                builder: (ctx, state) => EventDetailPage(
                  eventId: state.pathParameters['eventId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (ctx, state) => _fade(state, const ProfilePage()),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (ctx, state) => const EditProfilePage(),
              ),
            ],
          ),
        ],
      ),
      // Admin — outside shell (no bottom nav)
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

  // Dispose notifier when provider is disposed
  ref.onDispose(notifier.dispose);

  return router;
}, dependencies: [authStateProvider, currentUserProvider]);

CustomTransitionPage _fade(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (ctx, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}
