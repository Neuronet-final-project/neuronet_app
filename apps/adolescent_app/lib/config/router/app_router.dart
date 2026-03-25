import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Feature screens (placeholder imports)
import '../../features/journal/view/screens/journal_screen.dart';
import '../../features/mood/view/screens/mood_screen.dart';
import '../../features/dashboard/view/screens/dashboard_screen.dart';
import '../../features/ai_chat/view/screens/ai_chat_screen.dart';
import '../../features/channels/view/screens/channels_screen.dart';
import '../../features/channels/view/screens/channel_detail_screen.dart';
import '../../features/counselor_chat/view/screens/counselor_chat_screen.dart';
import '../../features/journal/view/screens/new_journal_entry_screen.dart';

/// Route names for the Adolescent app.
class AdolescentRoutes {
  const AdolescentRoutes._();

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
}

final adolescentRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AdolescentRoutes.home,
    routes: [
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
                builder: (context, state) => const JournalScreen(),
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
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return ChannelDetailScreen(channelId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      // Full-screen routes
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
    ],
  );
});

/// Shell widget with bottom navigation for the Adolescent app.
class AdolescentShell extends StatelessWidget {
  const AdolescentShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
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
        ],
      ),
    );
  }
}
