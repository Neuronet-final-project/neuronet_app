import 'dart:async';

import 'package:adolescent_app/features/dashboard/providers/dashboard_provider.dart';
import 'package:adolescent_app/features/auth/providers/auth_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'journal_provider.freezed.dart';
part 'journal_provider.g.dart';

@freezed
abstract class JournalState with _$JournalState {
  const factory JournalState({
    @Default([]) List<JournalEntry> entries,
    @Default(false) bool isLoading,
    String? error,
  }) = _JournalState;
}

/// One-shot message when optimistic save fails after the user has left the compose screen.
final journalBackgroundSaveErrorProvider =
    NotifierProvider<JournalBackgroundSaveErrorNotifier, String?>(
  JournalBackgroundSaveErrorNotifier.new,
);

class JournalBackgroundSaveErrorNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void clear() => state = null;

  void setMessage(String message) => state = message;
}

@riverpod
class JournalController extends _$JournalController {
  @override
  FutureOr<JournalState> build() async {
    ref.keepAlive();
    final service = ref.read(journalServiceProvider);
    final result = await service.getMyJournals();

    return result.when(
      success: (value) => JournalState(entries: value, isLoading: false),
      failure: (f) => JournalState(isLoading: false, error: f.message),
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(journalServiceProvider);
      final result = await service.getMyJournals();
      return result.when(
        success: (value) => JournalState(entries: value, isLoading: false),
        failure: (f) => JournalState(isLoading: false, error: f.message),
      );
    });
  }

  static const String _pendingIdPrefix = 'pending-';

  /// Inserts the entry into the list immediately, then persists to the API in the background.
  /// Does not await the network — use for instant navigation back to the journal list.
  void beginSaveEntry(String content, {String? title, MoodType? mood}) {
    ref.read(journalBackgroundSaveErrorProvider.notifier).clear();

    final priorEntries = state.value?.entries ?? const <JournalEntry>[];
    final resolvedMood = mood ?? MoodType.neutral;
    final adolescentId = _resolveAdolescentId(priorEntries);
    final now = DateTime.now();
    final pendingId = '$_pendingIdPrefix${now.microsecondsSinceEpoch}';

    final optimistic = JournalEntry(
      id: pendingId,
      adolescentId: adolescentId,
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
      mood: resolvedMood,
    );

    final merged = <JournalEntry>[
      optimistic,
      ...priorEntries,
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final current = state.value;
    state = AsyncValue.data(
      JournalState(
        entries: merged,
        isLoading: false,
        error: current?.error,
      ),
    );

    unawaited(_persistPendingEntry(
      pendingId: pendingId,
      content: content,
      title: title,
      mood: resolvedMood,
    ));
  }

  String _resolveAdolescentId(List<JournalEntry> priorEntries) {
    if (priorEntries.isNotEmpty) return priorEntries.first.adolescentId;
    final user = ref.read(authControllerProvider).user;
    return user?.getEffectiveId() ?? '';
  }

  Future<void> _persistPendingEntry({
    required String pendingId,
    required String content,
    String? title,
    required MoodType mood,
  }) async {
    final service = ref.read(journalServiceProvider);
    final request = CreateJournalRequest(
      title: title,
      content: content,
      mood: mood,
      deviceType: 'mobile',
    );

    final createResult = await service.createJournal(request);
    if (!ref.mounted) return;

    if (createResult.isFailure) {
      _dropPendingAndSetSaveError(
        pendingId,
        createResult.failure.message,
      );
      return;
    }

    final serverEntry = createResult.value;
    final current = state.value;
    if (current == null) return;

    final replaced = current.entries
        .map((e) => e.id == pendingId ? serverEntry : e)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    state = AsyncValue.data(
      JournalState(
        entries: replaced,
        isLoading: false,
        error: current.error,
      ),
    );

    // Refresh dashboard stats
    ref.invalidate(adolescentDashboardControllerProvider);

    unawaited(_reconcileWithServer());
  }

  void _dropPendingAndSetSaveError(String pendingId, String message) {
    final current = state.value;
    if (current == null) return;
    final filtered =
        current.entries.where((e) => e.id != pendingId).toList(growable: false);
    state = AsyncValue.data(
      JournalState(
        entries: filtered,
        isLoading: false,
        error: current.error,
      ),
    );
    ref.read(journalBackgroundSaveErrorProvider.notifier).setMessage(
          'Could not save your journal: $message. Your draft was removed — please try again.',
        );
  }

  /// Refreshes from the server without clearing the list (avoids blank history on slow networks).
  Future<void> _reconcileWithServer() async {
    final service = ref.read(journalServiceProvider);
    final getResult = await service.getMyJournals();
    if (!ref.mounted) return;
    getResult.when(
      success: (value) {
        final current = state.value;
        state = AsyncValue.data(
          JournalState(
            entries: value,
            isLoading: false,
            error: current?.error,
          ),
        );
      },
      failure: (_) {},
    );
  }
}
