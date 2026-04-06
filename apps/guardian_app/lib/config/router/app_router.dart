import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Feature screens
import '../../features/dashboard/view/screens/dashboard_screen.dart';
import '../../features/registration/view/screens/registration_screen.dart';
import '../../features/consent/view/screens/consent_screen.dart';
import '../../features/alerts/view/screens/alerts_screen.dart';
import '../../features/alerts/view/screens/alert_details_screen.dart';
import '../../features/counselor_msg/view/screens/counselor_msg_screen.dart';
import '../../features/profile/view/screens/profile_screen.dart';
import '../../features/auth/view/screens/login_screen.dart';
import '../../features/auth/view/screens/sign_up_screen.dart';
import '../../features/auth/view/screens/activation_screen.dart';
import '../../features/auth/view/screens/splash_screen.dart';
import '../../features/adolescents/view/screens/adolescent_detail_screen.dart';

// Auth Provider
import '../../features/auth/providers/auth_provider.dart';

/// Route names for the Guardian app.
class GuardianRoutes {
  const GuardianRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String activate = '/activate';
  static const String home = '/';
  static const String registerAdolescent = '/register-adolescent';
  static const String consent = '/consent';
  static const String alerts = '/alerts';
  static const String counselorMsg = '/counselor-messages';
  static const String profile = '/profile';
  static const String alertDetails = '/alert-details/:alertId';
  static const String adolescentDetails = '/adolescent/:adolescentId';
  static const String adolescentChat = '/adolescent/:adolescentId/chat';
}

// Global ChangeNotifier for auth state changes.
final _authChangeNotifier = _GuardianAuthChangeNotifier();

class _GuardianAuthChangeNotifier extends ChangeNotifier {
  AuthState _state = AuthState.initial();
  AuthState get state => _state;
  void update(AuthState s) {
    _state = s;
    notifyListeners();
  }
}

final guardianRouterProvider = Provider<GoRouter>((ref) {
  // Listen to auth changes WITHOUT rebuilding this provider.
  ref.listen(authControllerProvider, (_, authState) {
    _authChangeNotifier.update(authState);
  });

  return GoRouter(
    initialLocation: GuardianRoutes.splash,
    refreshListenable: _authChangeNotifier,
    redirect: (context, state) {
      final currentLocation = state.matchedLocation;
      final isLoggingIn = currentLocation == GuardianRoutes.login;
      final isSigningUp = currentLocation == GuardianRoutes.signup;
      final isActivating = currentLocation == GuardianRoutes.activate;
      final isSplash = currentLocation == GuardianRoutes.splash;

      final currentAuth = _authChangeNotifier.state;
      final isAuthenticated = currentAuth.status == AuthStatus.authenticated;
      final isInitial = currentAuth.status == AuthStatus.initial;
      final isLoading = currentAuth.status == AuthStatus.loading;

      // 1. True initial state (app just launched) — show splash
      if (isInitial) {
        return isSplash ? null : GuardianRoutes.splash;
      }

      // 2. Loading (login in progress, activation, etc.) — stay on current page
      if (isLoading) {
        return null;
      }

      // 3. Authenticated — redirect away from auth/splash pages
      if (isAuthenticated) {
        if (isLoggingIn || isActivating || isSigningUp || isSplash) return GuardianRoutes.home;
        return null;
      }

      // 4. Unauthenticated — send to login (even on error so user can retry)
      if (isLoggingIn || isActivating || isSigningUp) return null;
      return GuardianRoutes.login;
    },
    routes: [
      GoRoute(
        path: GuardianRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      // Auth Routes
      GoRoute(
        path: GuardianRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: GuardianRoutes.signup,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: GuardianRoutes.activate,
        builder: (context, state) => const ActivationScreen(),
      ),

      // Bottom navigation shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return GuardianShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: GuardianRoutes.home,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: GuardianRoutes.consent,
                builder: (context, state) => const ConsentScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: GuardianRoutes.alerts,
                builder: (context, state) => const AlertsScreen(),
                // Alert details moved to top-level for full-screen
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: GuardianRoutes.counselorMsg,
                builder: (context, state) => const CounselorMsgScreen(
                  adolescentId: '', // Default or placeholder
                  adolescentName: 'General',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: GuardianRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      
      // Full-screen routes
      GoRoute(
        path: GuardianRoutes.registerAdolescent,
        builder: (context, state) => const RegistrationScreen(),
      ),
    GoRoute(
        path: GuardianRoutes.alertDetails,
        builder: (context, state) {
          final alertId = state.pathParameters['alertId']!;
          return AlertDetailsScreen(alertId: alertId);
        },
      ),
      GoRoute(
        path: GuardianRoutes.adolescentDetails,
        builder: (context, state) {
          final adolescentId = state.pathParameters['adolescentId']!;
          return AdolescentDetailScreen(adolescentId: adolescentId);
        },
      ),
      GoRoute(
        path: GuardianRoutes.adolescentChat,
        builder: (context, state) {
          final adolescentId = state.pathParameters['adolescentId']!;
          final adolescentName = state.uri.queryParameters['name'] ?? 'Adolescent';
          return CounselorMsgScreen(
            adolescentId: adolescentId,
            adolescentName: adolescentName,
          );
        },
      ),
    ],
  );
});

/// Shell widget with bottom navigation for the Guardian app.
class GuardianShell extends StatelessWidget {
  const GuardianShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.verified_user_outlined),
            selectedIcon: Icon(Icons.verified_user),
            label: 'Consent',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.message_outlined),
            selectedIcon: Icon(Icons.message),
            label: 'Messages',
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
