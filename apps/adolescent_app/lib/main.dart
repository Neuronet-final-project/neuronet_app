import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'config/router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AdolescentApp()));
}

class AdolescentApp extends ConsumerWidget {
  const AdolescentApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(adolescentRouterProvider);

    return MaterialApp.router(
      title: 'NEURONET',
      debugShowCheckedModeBanner: false,
      theme: NeuroTheme.adolescentTheme(),
      routerConfig: router,
    );
  }
}
