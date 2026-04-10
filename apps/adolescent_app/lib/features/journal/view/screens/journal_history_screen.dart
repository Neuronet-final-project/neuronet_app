import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../../../config/router/app_router.dart';
import '../../providers/journal_provider.dart';

class JournalHistoryScreen extends ConsumerWidget {
  const JournalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalState = ref.watch(journalControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Journal'),
        actions: [
          IconButton(
            onPressed: () => ref.refresh(journalControllerProvider),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh journals',
          ),
        ],
      ),
      body: journalState.when(
        data: (entries) {
          if (entries.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: NeuroEmptyState(
                  title: 'No entries yet',
                  message: 'Start writing to track your thoughts and daily journey.',
                  icon: Icons.edit_note_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  actionLabel: 'Write First Entry',
                  onActionPressed: () => context.push(AdolescentRoutes.newJournal),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: NeuroJournalCard(
                  entry: entry,
                  onTap: () {
                    context.push('${AdolescentRoutes.journal}/${entry.id}');
                  },
                ),
              );
            },
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 4,
          itemBuilder: (context, index) => const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: NeuroSkeletonCard(),
          ),
        ),
        error: (error, stack) => Center(
          child: Text('Error loading journals: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AdolescentRoutes.newJournal),
        child: const Icon(Icons.add),
      ),
    );
  }
}
