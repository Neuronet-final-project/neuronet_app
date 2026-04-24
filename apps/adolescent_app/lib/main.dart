import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'config/router/app_router.dart';

import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';
import 'firebase_options.dart';

Future<void> main() async {
  debugPrint('>>> MAIN STARTING: Adolescent App <<<');
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
      builder: (context) => const ProviderScope(child: AdolescentApp()),
    ),
  );
}

class AdolescentApp extends ConsumerWidget {
  const AdolescentApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Wake up the notification service
    ref.watch(notificationServiceProvider);

    final router = ref.watch(adolescentRouterProvider);

    // Global listener: Automatically redirect user to Counselor Chat when receiving a call
    ref.listen(callControllerProvider, (previous, next) {
      final state = next.value;
      if (state != null && state.status == CallStatus.ringing && state.currentCall != null) {
        final currentCallId = state.currentCall!.id;
        final prevCallId = previous?.value?.currentCall?.id;
        
        // Avoid multi-pushing by verifying this is a fresh ring notification
        if (currentCallId != prevCallId) {
          debugPrint('[AdolescentApp] Incoming call from \${state.currentCall!.callerEmail}, navigating to chat...');
          router.go('/counselor-chat');
        }
      }
    });

    return MaterialApp.router(
      title: 'NEURONET',
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: NeuroTheme.adolescentTheme(),
      routerConfig: router,
    );
  }
}
