import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

part 'notification_service.g.dart';

@Riverpod(keepAlive: true)
class NotificationService extends _$NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  @override
  FutureOr<void> build() async {
    // Service is ready, but needs manual initialize() call after Firebase.initializeApp()
  }

  Future<void> initialize() async {
    debugPrint('[NotificationService] Initializing...');

    // 1. Request permissions (iOS/Android 13+)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('[NotificationService] User granted permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // 2. Get FCM token
      String? token = await _fcm.getToken();
      if (token != null) {
        debugPrint('[NotificationService] FCM Token: $token');
        await _registerTokenWithBackend(token);
      }

      // 3. Listen for token refreshes
      _fcm.onTokenRefresh.listen((newToken) {
        debugPrint('[NotificationService] Token refreshed: $newToken');
        _registerTokenWithBackend(newToken);
      });

      // 4. Configure local notifications for foreground messages
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: DarwinInitializationSettings(),
      );
      await _localNotifications.initialize(initializationSettings);

      // 5. Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // 6. Handle notification clicks when app is in background/terminated
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationClick);
    }
  }

  /// Manually trigger token registration with the backend.
  /// Call this after successful login.
  Future<void> triggerRegistration() async {
    debugPrint('[NotificationService] Manual registration trigger...');
    String? token = await _fcm.getToken();
    if (token != null) {
      debugPrint('[NotificationService] FCM Token for registration: $token');
      await _registerTokenWithBackend(token);
    } else {
      debugPrint('[NotificationService] No FCM token found during manual trigger');
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
    debugPrint('[NotificationService] Handling foreground message: ${message.notification?.title}');
    
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
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
