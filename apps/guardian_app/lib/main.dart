import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'config/router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: GuardianApp()));
}

class GuardianApp extends ConsumerWidget {
  const GuardianApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(guardianRouterProvider);

    return MaterialApp.router(
      title: 'NEURONET Guardian',
      debugShowCheckedModeBanner: false,
      theme: NeuroTheme.guardianTheme(),
      routerConfig: router,
    );
  }
}
