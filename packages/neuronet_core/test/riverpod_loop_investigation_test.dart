import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class LoopNotifier extends AsyncNotifier<int> {
  int buildCount = 0;
  
  @override
  FutureOr<int> build() {
    buildCount++;
    // We throw to simulate an error that might cause a loop if auto-disposed
    throw Exception('Error $buildCount');
  }
}

final loopProvider = AsyncNotifierProvider.autoDispose<LoopNotifier, int>(LoopNotifier.new);

class StableNotifier extends AsyncNotifier<int> {
  int buildCount = 0;
  
  @override
  FutureOr<int> build() {
    buildCount++;
    ref.keepAlive(); // STABILIZE: prevented from being disposed on error
    throw Exception('Error $buildCount');
  }
}

final stableProvider = AsyncNotifierProvider.autoDispose<StableNotifier, int>(StableNotifier.new);

void main() {
  test('AutoDispose provider without keepAlive is recreated on subsequent reads', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Initial read
    try {
      await container.read(loopProvider.future);
    } catch (_) {}

    expect(container.read(loopProvider.notifier).buildCount, 1);
    
    // Read again
    try {
      await container.read(loopProvider.future);
    } catch (_) {}
    
    // It should be 2 because it was disposed after the first error
    expect(container.read(loopProvider.notifier).buildCount, 2);
  });

  test('AutoDispose provider WITH keepAlive stays alive after error', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Initial read
    try {
      await container.read(stableProvider.future);
    } catch (_) {}

    expect(container.read(stableProvider.notifier).buildCount, 1);
    
    // Read again
    try {
      await container.read(stableProvider.future);
    } catch (_) {}
    
    // It should STILL be 1 because keepAlive prevented disposal
    expect(container.read(stableProvider.notifier).buildCount, 1);
  });
}
