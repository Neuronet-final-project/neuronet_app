import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Feature screens (placeholder imports)
import '../../features/dashboard/view/screens/dashboard_screen.dart';
import '../../features/registration/view/screens/registration_screen.dart';
import '../../features/consent/view/screens/consent_screen.dart';
import '../../features/alerts/view/screens/alerts_screen.dart';
import '../../features/alerts/view/screens/alert_details_screen.dart';
import '../../features/counselor_msg/view/screens/counselor_msg_screen.dart';
import '../../features/profile/view/screens/profile_screen.dart';

/// Route names for the Guardian app.
class GuardianRoutes {
  const GuardianRoutes._();

  static const String login = '/login';
  static const String activate = '/activate';
  static const String home = '/';
  static const String registerAdolescent = '/register-adolescent';
  static const String consent = '/consent';
  static const String alerts = '/alerts';
  static const String counselorMsg = '/counselor-messages';
  static const String profile = '/profile';
  static const String alertDetails = '/alerts/:alertId';
}

final guardianRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: GuardianRoutes.home,
    routes: [
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
                routes: [
                  GoRoute(
                    path: ':alertId',
                    builder: (context, state) => AlertDetailsScreen(
                      alertId: state.pathParameters['alertId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: GuardianRoutes.counselorMsg,
                builder: (context, state) => const CounselorMsgScreen(),
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
        onDestinationSelected: navigationShell.goBranch,
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
