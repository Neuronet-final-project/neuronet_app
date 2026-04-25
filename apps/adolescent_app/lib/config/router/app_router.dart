import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Feature screens (placeholder imports)
// Feature screens
import 'package:adolescent_app/features/journal/view/screens/journal_history_screen.dart';
import 'package:adolescent_app/features/mood/view/screens/mood_screen.dart';
import 'package:adolescent_app/features/dashboard/view/screens/dashboard_screen.dart';
import 'package:adolescent_app/features/ai_chat/view/screens/ai_chat_screen.dart';
import 'package:adolescent_app/features/channels/view/screens/channels_screen.dart';
import 'package:adolescent_app/features/channels/view/screens/channel_detail_screen.dart';
import 'package:adolescent_app/features/channels/view/screens/channel_post_detail_screen.dart';
import 'package:adolescent_app/features/counselor_chat/view/screens/counselor_chat_screen.dart';
import 'package:adolescent_app/features/counselor_chat/view/screens/request_approval_screen.dart';
import 'package:adolescent_app/features/journal/view/screens/new_journal_entry_screen.dart';
import 'package:adolescent_app/features/journal/view/screens/journal_search_screen.dart';
import 'package:adolescent_app/features/journal/providers/journal_provider.dart';
import 'package:adolescent_app/features/auth/view/screens/login_screen.dart';
import 'package:adolescent_app/features/auth/view/screens/activation_screen.dart';
import 'package:adolescent_app/features/auth/providers/auth_provider.dart';
import 'package:adolescent_app/features/journal/view/screens/journal_detail_screen.dart';
import 'package:adolescent_app/features/profile/view/screens/profile_screen.dart';
import 'package:adolescent_app/features/consent_status/view/screens/consent_status_screen.dart';
import 'package:adolescent_app/features/alerts/view/screens/alerts_screen.dart';
import 'package:adolescent_app/features/alerts/view/screens/alert_detail_screen.dart';
import 'package:adolescent_app/features/educational/view/screens/educational_library_screen.dart';
import 'package:adolescent_app/features/educational/view/screens/educational_page_detail_screen.dart';
import 'package:adolescent_app/features/educational/view/screens/recommendations_screen.dart';
import 'package:adolescent_app/features/educational/view/screens/discover_pages_screen.dart';
import 'package:adolescent_app/features/educational/view/screens/followed_pages_screen.dart';
import 'package:adolescent_app/features/auth/view/screens/splash_screen.dart';
import 'package:adolescent_app/features/onboarding/view/screens/onboarding_screen.dart';
import 'package:adolescent_app/features/activities/view/screens/activities_screen.dart';
import 'package:adolescent_app/features/activities/view/screens/breathing_exercise_screen.dart';
import 'package:adolescent_app/features/activities/view/screens/focus_game_screen.dart';
import 'package:adolescent_app/features/activities/view/screens/mood_matcher_screen.dart';
import 'package:adolescent_app/features/activities/view/screens/ai_quest_screen.dart';
import 'package:neuronet_core/neuronet_core.dart'; // For Alert and EducationalPage types in routing extra

/// Route names for the Adolescent app.
class AdolescentRoutes {
  const AdolescentRoutes._();

  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
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
  static const String requestApproval = '/request-approval';
  static const String profile = '/profile';
  static const String consentStatus = '/consent-status';
  static const String learn = '/learn';
  static const String discoverPages = '/discover-pages';
  static const String followedPages = '/followed-pages';
  static const String recommendations = '/recommendations';
  static const String activities = '/activities';
  static const String breathingExercise = '/breathing-exercise';
  static const String focusGame = '/focus-game';
  static const String moodMatcher = '/mood-matcher';
  static const String aiQuest = '/ai-quest';
  static const String alerts = '/alerts';
  static const String searchJournal = '/journal/search';
}

// Global ChangeNotifier for auth state changes.
// The GoRouter uses this as refreshListenable so it doesn't get recreated.
final authChangeNotifier = _AuthChangeNotifier();

class _AuthChangeNotifier extends ChangeNotifier {
  AuthState _state = AuthState.initial();
  AuthState get state => _state;
  void update(AuthState s) {
    _state = s;
    notifyListeners();
  }
}

final adolescentRouterProvider = Provider<GoRouter>((ref) {
  // Listen to auth changes WITHOUT rebuilding this provider.
  // The ChangeNotifier fires GoRouter.refresh() via refreshListenable.
  // Listen to auth changes.
  ref.listen(authControllerProvider, (_, authState) {
    authChangeNotifier.update(authState);
  });

  // Listen to onboarding status changes.
  ref.listen(onboardingStatusProvider, (_, __) {
    authChangeNotifier.notifyListeners();
  });

  return GoRouter(
    initialLocation: AdolescentRoutes.splash,
    refreshListenable: authChangeNotifier,
    redirect: (BuildContext context, GoRouterState state) {
      final currentLocation = state.matchedLocation;
      final isLoggingIn = currentLocation == AdolescentRoutes.login;
      final isActivating = currentLocation == AdolescentRoutes.activate;
      final isSplash = currentLocation == AdolescentRoutes.splash;
      final isOnboarding = currentLocation == AdolescentRoutes.onboarding;

      final currentAuth = authChangeNotifier.state;
      final isAuthenticated = currentAuth.status == AuthStatus.authenticated;
      final isInitial = currentAuth.status == AuthStatus.initial;
      final isLoading = currentAuth.status == AuthStatus.loading;

      // Access onboarding status
      final onboardingAsync = ref.read(onboardingStatusProvider);
      final onboardingComplete = onboardingAsync.value ?? false;

      debugPrint('[Router] redirect(current: $currentLocation, auth: ${currentAuth.status}, onboarding: $onboardingComplete)');

      // 1. True initial state (app just launched) or onboarding/auth still loading
      if (isInitial || onboardingAsync.isLoading) {
        debugPrint('[Router] Waiting for init (isInitial: $isInitial, onboardingLoading: ${onboardingAsync.isLoading})');
        return isSplash ? null : AdolescentRoutes.splash;
      }

      // 2. Check for Onboarding (only for unauthenticated users)
      if (!isAuthenticated && !isLoading) {
        if (!onboardingComplete && !isOnboarding) {
          debugPrint('[Router] Onboarding not complete, redirecting to /onboarding');
          return AdolescentRoutes.onboarding;
        }
      }

      // 3. Loading (login in progress, activation, etc.) — stay on current page
      if (isLoading) {
        debugPrint('[Router] isLoading, staying');
        return null;
      }

      // 4. Authenticated — redirect away from auth/splash/onboarding pages
      if (isAuthenticated) {
        if (isLoggingIn || isActivating || isSplash || isOnboarding) {
          debugPrint('[Router] isAuthenticated, redirecting to home');
          return AdolescentRoutes.home;
        }
        return null;
      }

      // 5. Unauthenticated or Error — send to login only if strictly unauthenticated.
      if (currentAuth.status == AuthStatus.error) {
        debugPrint('[Router] AuthStatus.error, staying on current page');
        return null;
      }

      if (isLoggingIn || isActivating || isOnboarding) return null;
      debugPrint('[Router] isUnauthenticated, redirecting to login');
      return AdolescentRoutes.login;
    },
    routes: [
      GoRoute(
        path: AdolescentRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AdolescentRoutes.onboarding,
        builder: (context, state) => const AdolescentOnboardingScreen(),
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
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return ChannelDetailScreen(channelId: id);
                    },
                    routes: [
                      GoRoute(
                        path: 'posts/:postId',
                        builder: (context, state) {
                          final channelId = state.pathParameters['id']!;
                          final postId = state.pathParameters['postId']!;
                          return ChannelPostDetailScreen(channelId: channelId, postId: postId);
                        },
                      ),
                    ],
                  ),
                ],
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
        path: AdolescentRoutes.requestApproval,
        builder: (context, state) {
          final extra = state.extra as Map<String, String>;
          return RequestApprovalScreen(
            counselorEmail: extra['email']!,
            counselorName: extra['name']!,
          );
        },
      ),
      GoRoute(
        path: AdolescentRoutes.newJournal,
        builder: (context, state) => const NewJournalEntryScreen(),
      ),
      GoRoute(
        path: AdolescentRoutes.searchJournal,
        builder: (context, state) {
          final journalState = ref.watch(journalControllerProvider);
          final extra = state.extra;
          DateTime? initialDate;
          if (extra is DateTime) initialDate = extra;

          return journalState.maybeWhen(
            data: (s) => JournalSearchScreen(
              entries: s.entries,
              initialDate: initialDate,
            ),
            orElse: () => const JournalSearchScreen(),
          );
        },
      ),
      GoRoute(
        path: '${AdolescentRoutes.journal}/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return JournalDetailScreen(entryId: id);
        },
      ),
      GoRoute(
        path: AdolescentRoutes.alerts,
        builder: (context, state) => const AdolescentAlertsScreen(),
      ),
      GoRoute(
        path: AdolescentRoutes.consentStatus,
        builder: (context, state) => const ConsentStatusScreen(),
      ),
      GoRoute(
        path: '${AdolescentRoutes.alerts}/:id',
        builder: (context, state) {
          final alertId = state.pathParameters['id']!;
          return AdolescentAlertDetailScreen(alertId: alertId);
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
        path: AdolescentRoutes.discoverPages,
        builder: (context, state) => const DiscoverPagesScreen(),
      ),
      GoRoute(
        path: AdolescentRoutes.followedPages,
        builder: (context, state) => const FollowedPagesScreen(),
      ),
      GoRoute(
        path: AdolescentRoutes.recommendations,
        builder: (context, state) => const RecommendationsScreen(),
      ),
      GoRoute(
        path: AdolescentRoutes.activities,
        builder: (context, state) => const ActivitiesScreen(),
      ),
      GoRoute(
        path: AdolescentRoutes.breathingExercise,
        builder: (context, state) => const BreathingExerciseScreen(),
      ),
      GoRoute(
        path: AdolescentRoutes.focusGame,
        builder: (context, state) => const FocusGameScreen(),
      ),
      GoRoute(
        path: AdolescentRoutes.moodMatcher,
        builder: (context, state) => const MoodMatcherScreen(),
      ),
      GoRoute(
        path: '/ai-quest', // Adding the new route
        builder: (context, state) => const AIQuestScreen(),
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
      body: SafeArea(child: navigationShell),
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
