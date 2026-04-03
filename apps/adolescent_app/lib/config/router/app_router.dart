import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Feature screens (placeholder imports)
import '../../features/journal/view/screens/journal_history_screen.dart';
import '../../features/mood/view/screens/mood_screen.dart';
import '../../features/dashboard/view/screens/dashboard_screen.dart';
import '../../features/ai_chat/view/screens/ai_chat_screen.dart';
import '../../features/channels/view/screens/channels_screen.dart';
import '../../features/channels/view/screens/channel_detail_screen.dart';
import '../../features/counselor_chat/view/screens/counselor_chat_screen.dart';
import '../../features/journal/view/screens/new_journal_entry_screen.dart';
import '../../features/auth/view/screens/login_screen.dart';
import '../../features/auth/view/screens/activation_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/journal/view/screens/journal_detail_screen.dart';
import '../../features/profile/view/screens/profile_screen.dart';
import '../../features/alerts/view/screens/alerts_screen.dart';
import '../../features/alerts/view/screens/alert_detail_screen.dart';
import '../../features/educational/view/screens/educational_library_screen.dart';
import '../../features/educational/view/screens/educational_page_detail_screen.dart';
import '../../features/educational/view/screens/recommendations_screen.dart';
import '../../features/auth/view/screens/splash_screen.dart';
import 'package:neuronet_core/neuronet_core.dart'; // For Alert and EducationalPage types in routing extra

/// Route names for the Adolescent app.
class AdolescentRoutes {
  const AdolescentRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String activate = '/activate';
  static const String home = '/';
  static const String journal = '/journal';
  static const String newJournal = '/journal/new';
  static const String mood = '/mood';
  static const String aiChat = '/ai-chat';
  static const String dashboard = '/dashboard';
  static const String channels = '/channels';
  static const String counselorChat = '/counselor-chat';
  static const String profile = '/profile';
  static const String alerts = '/alerts';
  static const String learn = '/learn';
  static const String recommendations = '/recommendations';
}

final adolescentRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: AdolescentRoutes.splash,
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggingIn = state.matchedLocation == AdolescentRoutes.login;
      final isActivating = state.matchedLocation == AdolescentRoutes.activate;
      final isSplash = state.matchedLocation == AdolescentRoutes.splash;

      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isInitial = authState.status == AuthStatus.initial || authState.status == AuthStatus.loading;

      if (isInitial) {
        return isSplash ? null : AdolescentRoutes.splash;
      }

      if (isAuthenticated) {
        if (isLoggingIn || isActivating || isSplash) return AdolescentRoutes.home;
        return null;
      } else {
        // If we are loading or there was a data error, don't redirect yet
        if (authState.status == AuthStatus.error) return null;
        
        if (isLoggingIn || isActivating) return null;
        return AdolescentRoutes.login;
      }
    },
    routes: [
      GoRoute(
        path: AdolescentRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      // Auth routes
      GoRoute(
        path: AdolescentRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AdolescentRoutes.activate,
        builder: (context, state) => const ActivationScreen(),
      ),
      // Bottom navigation shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AdolescentShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AdolescentRoutes.home,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AdolescentRoutes.journal,
                builder: (context, state) => const JournalHistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AdolescentRoutes.mood,
                builder: (context, state) => const MoodScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AdolescentRoutes.channels,
                builder: (context, state) => const ChannelsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AdolescentRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AdolescentRoutes.aiChat,
        builder: (context, state) => const AiChatScreen(),
      ),
      GoRoute(
        path: AdolescentRoutes.counselorChat,
        builder: (context, state) => const CounselorChatScreen(),
      ),
      GoRoute(
        path: AdolescentRoutes.newJournal,
        builder: (context, state) => const NewJournalEntryScreen(),
      ),
      GoRoute(
        path: '${AdolescentRoutes.journal}/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return JournalDetailScreen(entryId: id);
        },
      ),
      GoRoute(
        path: '${AdolescentRoutes.channels}/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ChannelDetailScreen(channelId: id);
        },
      ),
      GoRoute(
        path: AdolescentRoutes.alerts,
        builder: (context, state) => const AdolescentAlertsScreen(),
      ),
      GoRoute(
        path: '${AdolescentRoutes.alerts}/:id',
        builder: (context, state) {
          final alert = state.extra as Alert;
          return AdolescentAlertDetailScreen(alert: alert);
        },
      ),
      GoRoute(
        path: AdolescentRoutes.learn,
        builder: (context, state) => const EducationalLibraryScreen(),
      ),
      GoRoute(
        path: '${AdolescentRoutes.learn}/:slug',
        builder: (context, state) {
          final page = state.extra as EducationalPage;
          return EducationalPageDetailScreen(page: page);
        },
      ),
      GoRoute(
        path: AdolescentRoutes.recommendations,
        builder: (context, state) => const RecommendationsScreen(),
      ),
    ],
  );
});

/// Shell widget with bottom navigation for the Adolescent app.
class AdolescentShell extends ConsumerWidget {
  const AdolescentShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Journal',
          ),
          NavigationDestination(
            icon: Icon(Icons.mood_outlined),
            selectedIcon: Icon(Icons.mood),
            label: 'Mood',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum),
            label: 'Channels',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
