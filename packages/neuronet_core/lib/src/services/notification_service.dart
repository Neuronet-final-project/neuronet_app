import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';
import '../network/providers.dart';

part 'notification_service.g.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `Firebase.initializeApp()` before using other Firebase services.
  await Firebase.initializeApp();
  debugPrint('[NotificationService] Handling background message: ${message.messageId}');
}

@Riverpod(keepAlive: true)
class NotificationService extends _$NotificationService {
  FirebaseMessaging? _fcm;
  FlutterLocalNotificationsPlugin? _localNotifications;
  bool _initialized = false;
  Completer<void>? _initCompleter;
  final List<StreamSubscription> _subscriptions = [];

  @override
  FutureOr<void> build() async {
    // We don't await here to keep build() sync-like, but it starts the process
    _initializeInternal();
    
    // Cleanup on dispose
    ref.onDispose(() {
      for (var sub in _subscriptions) {
        sub.cancel();
      }
      _subscriptions.clear();
      _initialized = false;
      _initCompleter = null;
    });
  }

  Future<void> _initializeInternal() async {
    if (_initialized) return;
    if (_initCompleter != null) return _initCompleter!.future;
    
    _initCompleter = Completer<void>();
    
    try {
      // Small delay to ensure native Firebase services are fully ready
      await Future.delayed(const Duration(milliseconds: 500));
      
      debugPrint('[NotificationService] Initializing...');
      _fcm = FirebaseMessaging.instance;
      _localNotifications = FlutterLocalNotificationsPlugin();
      
      NotificationSettings settings = await _fcm!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint('[NotificationService] User granted permission: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized || 
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // 2. Get FCM token
        String? token = await _fcm!.getToken();
        if (token != null) {
          debugPrint('[NotificationService] FCM Token: $token');
          // Check for token before registering to avoid 401 spam
          final storage = ref.read(tokenStorageProvider);
          final accessToken = await storage.getAccessToken();
          if (accessToken != null) {
            await _registerTokenWithBackend(token);
          }
        }

        // 3. Listen for token refreshes
        _subscriptions.add(_fcm!.onTokenRefresh.listen((newToken) {
          debugPrint('[NotificationService] Token refreshed: $newToken');
          _registerTokenWithBackend(newToken);
        }));

        // 4. Configure local notifications for foreground messages
        const AndroidInitializationSettings initializationSettingsAndroid =
            AndroidInitializationSettings('@mipmap/ic_launcher');
        const InitializationSettings initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: DarwinInitializationSettings(),
        );
        await _localNotifications!.initialize(initializationSettings);

        // Create high importance channel for Android
        await _localNotifications!
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(const AndroidNotificationChannel(
              'high_importance_channel',
              'High Importance Notifications',
              description: 'This channel is used for important notifications.',
              importance: Importance.max,
            ));

        // 5. Handle foreground messages
        _subscriptions.add(FirebaseMessaging.onMessage.listen(_handleForegroundMessage));

        // 5.5 Handle background messages
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

        // 6. Handle notification clicks when app is in background/terminated
        _subscriptions.add(FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationClick));
        
        _initialized = true;
      }
    } catch (e, stack) {
      debugPrint('[NotificationService] Initialization failed: $e');
      if (kDebugMode) {
        debugPrint(stack.toString());
      }
    } finally {
      _initCompleter?.complete();
    }
  }

  /// Manually trigger token registration with the backend.
  /// Call this after successful login.
  Future<void> triggerRegistration() async {
    if (!_initialized) {
      await _initializeInternal();
    }
    
    String? token = await _fcm?.getToken();
    if (token != null) {
      await _registerTokenWithBackend(token);
    }
  }

  Future<void> _registerTokenWithBackend(String token) async {
    // Only register if we are likely to be authenticated
    // Note: This service might build before AuthState is fully resolved
    // In a real app, you'd watch AuthState, but here we'll provide a manual trigger or try-catch
    try {
      final auth = ref.read(authServiceProvider);
      // We don't have a direct "isAuthenticated" on the service itself usually,
      // but we can try to call the API. The API client will handle 401s.
      await auth.registerDeviceToken(token);
      debugPrint('[NotificationService] Token registered with backend successfully');
    } catch (e) {
      debugPrint('[NotificationService] Failed to register token with backend (expected if not logged in): $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('[NotificationService] Handling foreground message: ${message.notification?.title ?? "Data only"}');
    
    RemoteNotification? notification = message.notification;
    String? title = notification?.title;
    String? body = notification?.body;

    // Fallback for data-only messages (useful if backend doesn't include 'notification' block)
    if (title == null && body == null && message.data.containsKey('type')) {
      if (message.data['type'] == 'chat') {
        title = 'New Message';
        body = 'You received a message in your chat';
      } else {
        title = 'System Update';
        body = 'You have a new notification';
      }
    }

    if (title != null && _localNotifications != null) {
      final id = DateTime.now().millisecondsSinceEpoch % 1000000;
      debugPrint('[NotificationService] Displaying local notification: $title (ID: $id)');
      
      _localNotifications!.show(
        id,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data['type'],
      );
    }
  }

  void _handleNotificationClick(RemoteMessage message) {
    debugPrint('[NotificationService] Notification clicked: ${message.data}');
    // In a real app, use ref.read(routerProvider) to navigate based on message.data
  }
}
