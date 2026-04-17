import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../providers/journal_provider.dart';

class JournalDetailScreen extends ConsumerWidget {
  const JournalDetailScreen({super.key, required this.entryId});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalAsync = ref.watch(journalControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Entry'),
      ),
      body: journalAsync.when(
        data: (state) {
          if (state.isLoading && state.entries.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null && state.entries.isEmpty) {
            return Center(child: Text('Error: ${state.error}'));
          }

          final entry = state.entries.firstWhere(
            (e) => e.id == entryId,
            orElse: () => throw Exception('Entry not found'),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      entry.mood?.emoji ?? '📝',
                      style: const TextStyle(fontSize: 40),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.mood?.label ?? 'Journal',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          entry.createdAt.toString(), // Simple format for now
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: NeuroColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(NeuroRadius.xl),
                  decoration: BoxDecoration(
                    color: NeuroColors.surface,
                    borderRadius: BorderRadius.circular(NeuroRadius.xl),
                    boxShadow: [NeuroShadows.md],
                  ),
                  child: Text(
                    entry.content,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: NeuroColors.adolescentSurface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock_outline, size: 16, color: NeuroColors.adolescentPrimary),
                        const SizedBox(width: 8),
                        Text(
                          'End-to-End Encrypted',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: NeuroColors.adolescentPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
