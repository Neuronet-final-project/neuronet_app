import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:adolescent_app/features/journal/providers/journal_provider.dart';

class MockJournalService extends Mock implements JournalService {}

void main() {
  late MockJournalService mockService;

  setUp(() {
    mockService = MockJournalService();
  });

  test('JournalController STABLE build test on error (No Throw)', () async {
    int buildCount = 0;

    final container = ProviderContainer(
      overrides: [
        journalServiceProvider.overrideWith((ref) {
          buildCount++;
          return mockService;
        }),
      ],
    );
    addTearDown(container.dispose);

    // Initial load failure - the service returns Result.failure, but Notifier.build() should NOT throw
    when(() => mockService.getMyJournals()).thenAnswer(
      (_) async => const Result.failure(UnknownFailure(message: 'Persistent Error')),
    );

    // 1. First build
    final asyncState = container.read(journalControllerProvider);
    expect(asyncState.isLoading, true);
    expect(buildCount, 1);

    // Wait for the async build to complete
    final finalState = await container.read(journalControllerProvider.future);
    
    expect(finalState.isLoading, false);
    expect(finalState.error, 'Persistent Error');
    expect(buildCount, 1, reason: 'Build should ONLY be called once');

    // 2. Read again - should definitely NOT rebuild
    final secondReadState = await container.read(journalControllerProvider.future);
    expect(secondReadState.error, 'Persistent Error');
    expect(buildCount, 1);
    
  });
}
