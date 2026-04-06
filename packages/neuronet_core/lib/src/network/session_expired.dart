import 'package:flutter/foundation.dart';

/// Global notifier fired when the auth interceptor clears tokens due to
/// an unrecoverable 401 (token expired and refresh failed).
///
/// Auth providers in both apps should listen to this and set their state
/// to unauthenticated, triggering a router redirect.
final sessionExpiredNotifier = ValueNotifier<int>(0);

/// Call this when the auth interceptor detects a session expiry.
/// Increments the counter to notify all listeners.
void notifySessionExpired() {
  sessionExpiredNotifier.value++;
}
