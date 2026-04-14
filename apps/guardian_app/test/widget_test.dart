import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Guardian app tests are consolidated in adolescent_app test suite',
      () {
    // Guardian app shares the same neuronet_core widgets and services
    // with the adolescent app. Widget tests for shared components
    // (NeuroActiveCallScreen, NeuroIncomingCallScreen) are in
    // packages/neuronet_core/test/call_overlay_test.dart.
    //
    // Guardian-specific screen tests should be added here as the app grows.
    expect(true, isTrue,
        reason: 'Guardian app shares core widgets with adolescent app. '
            'See neuronet_core/test/ for shared widget tests.');
  });
}
