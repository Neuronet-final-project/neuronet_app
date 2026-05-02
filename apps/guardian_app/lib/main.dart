import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'config/router/app_router.dart';
import 'config/theme/guardian_theme.dart';

import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';
import 'firebase_options.dart';

Future<void> main() async {
  debugPrint('>>> MAIN STARTING: Guardian App <<<');
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
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('>>> FIREBASE INITIALIZED <<<');
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
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

class GuardianApp extends ConsumerStatefulWidget {
  const GuardianApp({super.key});

  @override
  ConsumerState<GuardianApp> createState() => _GuardianAppState();
}

class _GuardianAppState extends ConsumerState<GuardianApp> {
  @override
  void initState() {
    super.initState();
    // Initialize localization
    Future.microtask(() => ref.read(l10nProvider.notifier).initialize());
  }

  @override
  Widget build(BuildContext context) {
    // Wake up the notification service
    ref.watch(notificationServiceProvider);

    final router = ref.watch(guardianRouterProvider);
    final currentLocale = ref.watch(l10nProvider);

    return MaterialApp.router(
      title: 'NEURONET Guardian',
      debugShowCheckedModeBanner: false,
      locale: currentLocale,
      localizationsDelegates: neuroLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: DevicePreview.appBuilder,
      theme: GuardianTheme.build(),
      routerConfig: router,
    );
  }
}
