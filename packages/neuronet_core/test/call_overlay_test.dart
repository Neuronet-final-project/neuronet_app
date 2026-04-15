import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────

class MockCallController extends AsyncNotifier<CallState> with Mock
    implements CallController {}

class MockCallService extends Mock implements CallService {}

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

/// A test widget that replicates the Stack-based inline overlay architecture
/// used in both counselor chat screens.
class CallOverlayTestWidget extends StatelessWidget {
  final CallState callState;
  final Color accentColor;

  const CallOverlayTestWidget({
    super.key,
    required this.callState,
    this.accentColor = const Color(0xFF009688),
  });

  @override
  Widget build(BuildContext context) {
    final showIncomingCall =
        callState.status == CallStatus.ringing && callState.currentCall != null;
    // Show active call for: answered, active, OR initiated (caller waiting)
    final showActiveCall =
        callState.currentCall != null &&
        (callState.status == CallStatus.active ||
            callState.status == CallStatus.answered ||
            callState.status == CallStatus.initiated);

    return Scaffold(
      body: Stack(
        children: [
          // Chat content underneath
          const Center(child: Text('Chat Content')),
          // Incoming call overlay
          if (showIncomingCall)
            NeuroIncomingCallScreen(
              incomingCall: callState.currentCall!,
              accentColor: accentColor,
              onDismissed: () {},
            ),
          // Active call overlay
          if (showActiveCall)
            NeuroActiveCallScreen(
              call: callState.currentCall!,
              remotePeerEmail: callState.remotePeerEmail ?? 'unknown@test.com',
              accentColor: accentColor,
            ),
        ],
      ),
    );
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(const CallState());
    registerFallbackValue(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ));
    registerFallbackValue(NotificationResponse(
      notificationResponseType: NotificationResponseType.selectedNotification,
    ));
  });

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Stub WebRTC method channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('FlutterWebRTC.Method'),
            (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'createPeerConnection':
          return {'peerConnectionId': 'pc_1'};
        case 'createOffer':
          return {'type': 'offer', 'sdp': 'v=0\r\no=- 4711'};
        case 'createAnswer':
          return {'type': 'answer', 'sdp': 'v=0\r\no=- 4711'};
        case 'setLocalDescription':
        case 'setRemoteDescription':
          return null;
        case 'getUserMedia':
          return {'streamId': 'stream_1', 'tracks': []};
        case 'createVideoRenderer':
          return {'textureId': 1};
        default:
          return null;
      }
    });

    // Stub notifications
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('dexterous.com/flutter/local_notifications'),
            (MethodCall methodCall) async {
      if (methodCall.method == 'initialize') return true;
      return null;
    });
  });

  Widget buildTestWidget({
    required Widget child,
    CallState? initialState,
  }) {
    final mockController = MockCallController();
    final mockNotifications = MockFlutterLocalNotificationsPlugin();

    when(() => mockController.build())
        .thenAnswer((_) async => initialState ?? const CallState());
    when(() => mockNotifications.initialize(
          any(),
          onDidReceiveNotificationResponse:
              any(named: 'onDidReceiveNotificationResponse'),
          onDidReceiveBackgroundNotificationResponse:
              any(named: 'onDidReceiveBackgroundNotificationResponse'),
        )).thenAnswer((_) async => true);
    when(() => mockNotifications.show(
          any(),
          any(),
          any(),
          any(),
          payload: any(named: 'payload'),
        )).thenAnswer((_) async => {});

    return ProviderScope(
      overrides: [
        callControllerProvider.overrideWith(() => mockController),
        notificationPluginProvider.overrideWithValue(mockNotifications),
      ],
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: child,
      ),
    );
  }

  final dt = DateTime.utc(2026, 4, 6, 12, 0, 0);
  final testCall = Call(
    id: 'c1',
    conversationId: 'conv1',
    callType: CallType.voice,
    status: CallStatus.ringing,
    callerEmail: 'caller@test.com',
    callerName: 'Caller One',
    createdAt: dt,
  );

  // ── Inline Overlay Tests ───────────────────────────────────────────────────

  group('Inline Call Overlay Architecture', () {
    testWidgets('shows incoming call overlay when status is ringing',
        (WidgetTester tester) async {
      final callState = CallState(
        currentCall: testCall,
        status: CallStatus.ringing,
        remotePeerEmail: 'caller@test.com',
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: CallOverlayTestWidget(callState: callState),
          initialState: callState,
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should show the incoming call UI elements (caller name + buttons)
      expect(find.text('Caller One'), findsOneWidget);
      expect(find.byIcon(Icons.call), findsOneWidget); // Accept button
      expect(find.byIcon(Icons.call_end), findsOneWidget); // Decline button
    });

    testWidgets('shows active call overlay when isInCall and not ringing',
        (WidgetTester tester) async {
      final activeCall = testCall.copyWith(status: CallStatus.active);
      final callState = CallState(
        currentCall: activeCall,
        status: CallStatus.active,
        remotePeerEmail: 'caller@test.com',
        duration: const Duration(seconds: 15),
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: CallOverlayTestWidget(callState: callState),
          initialState: callState,
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should show the active call UI
      expect(find.textContaining('Caller'), findsOneWidget);
      expect(find.byKey(const ValueKey('end_call_button')), findsOneWidget);
      expect(find.byKey(const ValueKey('mute_button')), findsOneWidget);
    });

    testWidgets('shows active call overlay when caller status is initiated',
        (WidgetTester tester) async {
      // Caller initiated a call — should see the active call UI (not incoming)
      final initiatedCall = testCall.copyWith(status: CallStatus.initiated);
      final callState = CallState(
        currentCall: initiatedCall,
        status: CallStatus.initiated,
        remotePeerEmail: 'callee@test.com',
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: CallOverlayTestWidget(callState: callState),
          initialState: callState,
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should show the active call UI with end button (to cancel the call)
      expect(find.byKey(const ValueKey('end_call_button')), findsOneWidget);
    });

    testWidgets('hides overlay when call status is ended',
        (WidgetTester tester) async {
      final endedCall = testCall.copyWith(status: CallStatus.ended);
      final callState = CallState(
        currentCall: endedCall,
        status: CallStatus.ended,
        remotePeerEmail: 'caller@test.com',
        duration: const Duration(seconds: 30),
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: CallOverlayTestWidget(callState: callState),
          initialState: callState,
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Overlay should NOT be visible — only the chat content underneath
      expect(find.textContaining('Incoming'), findsNothing);
      expect(find.textContaining('Caller'), findsNothing);
      expect(find.text('Chat Content'), findsOneWidget);
    });

    testWidgets('hides overlay when call status is rejected',
        (WidgetTester tester) async {
      final rejectedCall = testCall.copyWith(status: CallStatus.rejected);
      final callState = CallState(
        currentCall: rejectedCall,
        status: CallStatus.rejected,
        remotePeerEmail: 'caller@test.com',
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: CallOverlayTestWidget(callState: callState),
          initialState: callState,
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Overlay should NOT be visible
      expect(find.textContaining('Incoming'), findsNothing);
      expect(find.text('Chat Content'), findsOneWidget);
    });

    testWidgets('does not show overlay when currentCall is null',
        (WidgetTester tester) async {
      final callState = const CallState(
        currentCall: null,
        status: CallStatus.initiated,
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: CallOverlayTestWidget(callState: callState),
          initialState: callState,
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Incoming'), findsNothing);
      expect(find.text('Chat Content'), findsOneWidget);
    });

    testWidgets('accept call button is visible in incoming call overlay',
        (WidgetTester tester) async {
      final callState = CallState(
        currentCall: testCall,
        status: CallStatus.ringing,
        remotePeerEmail: 'caller@test.com',
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: CallOverlayTestWidget(callState: callState),
          initialState: callState,
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Accept button should be visible
      expect(find.byIcon(Icons.call), findsOneWidget);
    });

    testWidgets('decline call button is visible in incoming call overlay',
        (WidgetTester tester) async {
      final callState = CallState(
        currentCall: testCall,
        status: CallStatus.ringing,
        remotePeerEmail: 'caller@test.com',
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: CallOverlayTestWidget(callState: callState),
          initialState: callState,
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Decline button should be visible
      expect(find.byIcon(Icons.call_end), findsOneWidget);
    });
  });

  // ── NeuroIncomingCallScreen Tests ──────────────────────────────────────────

  group('NeuroIncomingCallScreen', () {
    testWidgets('displays caller name from call model',
        (WidgetTester tester) async {
      final mockController = MockCallController();
      when(() => mockController.build())
          .thenAnswer((_) async => const CallState());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            callControllerProvider.overrideWith(() => mockController),
          ],
          child: MaterialApp(
            home: NeuroIncomingCallScreen(
              incomingCall: testCall,
              accentColor: const Color(0xFF009688),
              onDismissed: () {},
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should show caller name
      expect(find.text('Caller One'), findsOneWidget);
    });
  });

  // ── NeuroActiveCallScreen Tests ────────────────────────────────────────────

  group('NeuroActiveCallScreen', () {
    testWidgets('renders voice call UI with correct elements',
        (WidgetTester tester) async {
      final activeCall = testCall.copyWith(status: CallStatus.active);

      final mockController = MockCallController();
      when(() => mockController.build()).thenAnswer((_) async => CallState(
            currentCall: activeCall,
            status: CallStatus.active,
            remotePeerEmail: 'caller@test.com',
            duration: const Duration(seconds: 15),
          ));

      await tester.runAsync(() async {
        await tester.pumpWidget(ProviderScope(
          overrides: [
            callControllerProvider.overrideWith(() => mockController),
          ],
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: NeuroActiveCallScreen(
              call: activeCall,
              remotePeerEmail: 'caller@test.com',
            ),
          ),
        ));

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      });

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.textContaining('Call Error'), findsNothing);
      expect(find.textContaining('Caller'), findsOneWidget);

      // Find buttons by their label text (new pattern)
      expect(find.text('End Call'), findsOneWidget);
      expect(find.text('Mute'), findsOneWidget);
    });

    testWidgets('renders video call UI with correct elements',
        (WidgetTester tester) async {
      final videoCall =
          testCall.copyWith(callType: CallType.video, status: CallStatus.active);

      final mockController = MockCallController();
      when(() => mockController.build()).thenAnswer((_) async => CallState(
            currentCall: videoCall,
            status: CallStatus.active,
            remotePeerEmail: 'caller@test.com',
            isCameraOn: true,
            isMuted: true,
          ));

      await tester.runAsync(() async {
        await tester.pumpWidget(ProviderScope(
          overrides: [
            callControllerProvider.overrideWith(() => mockController),
          ],
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: NeuroActiveCallScreen(
              call: videoCall,
              remotePeerEmail: 'caller@test.com',
            ),
          ),
        ));

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      });

      expect(find.textContaining('Caller'), findsOneWidget);

      // Find end call button by label
      expect(find.text('End Call'), findsOneWidget);
    });

    testWidgets('mute button calls toggleMute on controller',
        (WidgetTester tester) async {
      final activeCall = testCall.copyWith(status: CallStatus.active);

      final mockController = MockCallController();
      when(() => mockController.build()).thenAnswer((_) async => CallState(
            currentCall: activeCall,
            status: CallStatus.active,
            remotePeerEmail: 'caller@test.com',
          ));
      when(() => mockController.toggleMute()).thenAnswer((_) async {});

      await tester.runAsync(() async {
        await tester.pumpWidget(ProviderScope(
          overrides: [
            callControllerProvider.overrideWith(() => mockController),
          ],
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: NeuroActiveCallScreen(
              call: activeCall,
              remotePeerEmail: 'caller@test.com',
            ),
          ),
        ));

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      });

      final muteButton = find.byKey(const ValueKey('mute_button'));
      expect(muteButton, findsOneWidget);

      await tester.tap(muteButton);
      await tester.pump();

      verify(() => mockController.toggleMute()).called(1);
    });

    testWidgets('end call button calls endCall on controller',
        (WidgetTester tester) async {
      final activeCall = testCall.copyWith(status: CallStatus.active);

      final mockController = MockCallController();
      when(() => mockController.build()).thenAnswer((_) async => CallState(
            currentCall: activeCall,
            status: CallStatus.active,
            remotePeerEmail: 'caller@test.com',
          ));
      when(() => mockController.endCall()).thenAnswer((_) async {});

      await tester.runAsync(() async {
        await tester.pumpWidget(ProviderScope(
          overrides: [
            callControllerProvider.overrideWith(() => mockController),
          ],
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: NeuroActiveCallScreen(
              call: activeCall,
              remotePeerEmail: 'caller@test.com',
            ),
          ),
        ));

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      });

      final endButton = find.byKey(const ValueKey('end_call_button'));
      expect(endButton, findsOneWidget);

      await tester.tap(endButton);
      await tester.pump();

      verify(() => mockController.endCall()).called(1);
    });
  });
}
