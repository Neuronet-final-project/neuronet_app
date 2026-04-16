import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'config/router/app_router.dart';

import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String baseUrl = ApiEndpoints.baseUrl;
  if (!kIsWeb) {
    try {
      await dotenv.load(fileName: '.env');
      baseUrl = dotenv.env['BASE_URL'] ?? baseUrl;
    } catch (_) {}
  }
  ApiEndpoints.init(baseUrl: baseUrl);

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

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
    // Initialize Notification Service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationServiceProvider.notifier).initialize();
    });

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
