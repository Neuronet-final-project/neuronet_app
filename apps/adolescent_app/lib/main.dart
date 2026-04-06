import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
    final router = ref.watch(adolescentRouterProvider);

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
