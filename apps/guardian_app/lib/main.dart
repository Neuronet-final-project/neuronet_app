import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'config/router/app_router.dart';

import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    DevicePreview(
      enabled: kIsWeb,
      builder: (context) => const ProviderScope(child: GuardianApp()),
    ),
  );
}

class GuardianApp extends ConsumerWidget {
  const GuardianApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(guardianRouterProvider);

    return MaterialApp.router(
      title: 'NEURONET Guardian',
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: NeuroTheme.guardianTheme(),
      routerConfig: router,
    );
  }
}
