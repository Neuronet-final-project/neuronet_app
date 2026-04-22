import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:intl/intl.dart';
import '../../../../config/router/app_router.dart';
import '../../providers/journal_provider.dart';

class JournalHistoryScreen extends ConsumerWidget {
  const JournalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalAsync = ref.watch(journalControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: journalAsync.when(
        data: (state) => _JournalContent(state: state),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $err'),
              ElevatedButton(
                onPressed: () => ref.read(journalControllerProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AdolescentRoutes.newJournal),
        backgroundColor: const Color(0xFF7C4DFF),
        child: const Icon(Icons.edit_rounded, color: Colors.white),
      ),
    );
  }
}

class _JournalContent extends ConsumerWidget {
  const _JournalContent({required this.state});
  final JournalState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () => ref.read(journalControllerProvider.notifier).refresh(),
      child: CustomScrollView(
        slivers: [
          _JournalHeader(entriesCount: state.entries.length),
          SliverToBoxAdapter(child: _FilterBar()),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: state.entries.isEmpty
                ? const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text('No journal entries yet.')),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entry = state.entries[index];
                        return _EntryCard(entry: entry);
                      },
                      childCount: state.entries.length,
                    ),
                  ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _JournalHeader extends ConsumerWidget {
  const _JournalHeader({required this.entriesCount});
  final int entriesCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPadding = MediaQuery.of(context).padding.top;
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFF7C4DFF),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A1FDB), Color(0xFF7C4DFF), Color(0xFF64B5F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, topPadding + 24, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Journal',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'A safe space for your thoughts',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => ref.read(journalControllerProvider.notifier).refresh(),
                      icon: const Icon(Icons.sync_rounded, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(child: _StatCard(label: 'Entries', value: '$entriesCount', icon: Icons.book_outlined)),
                    const SizedBox(width: 12),
                    const Expanded(child: _StatCard(label: 'Streak', value: '5 days', icon: Icons.bolt_outlined)),
                    const SizedBox(width: 12),
                    const Expanded(child: _StatCard(label: 'This week', value: '+3', icon: Icons.favorite_outline)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _FilterChip(label: 'All', isSelected: true),
            _FilterChip(label: 'This Week'),
            _FilterChip(label: 'Happy'),
            _FilterChip(label: 'Calm'),
            _FilterChip(label: 'Anxious'),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  _FilterChip({required this.label, this.isSelected = false});
  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF7C4DFF) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? Colors.transparent : Colors.black12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black54,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry});
  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final moodColor = _getMoodColor(entry.mood);
    return GestureDetector(
      onTap: () => context.push('${AdolescentRoutes.journal}/${entry.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 6,
                height: 140, // Height will be constrained by content mostly
                color: moodColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: moodColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(_getMoodEmoji(entry.mood), style: const TextStyle(fontSize: 20)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.title ?? 'Untitled Entry',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                Text(
                                  DateFormat('MMM d · h:mm a').format(entry.createdAt),
                                  style: const TextStyle(color: Colors.black38, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right_rounded, color: Color(0xFF7C4DFF), size: 20),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        entry.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.6),
                          height: 1.5,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              entry.mood?.name.toUpperCase() ?? 'NEUTRAL',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Colors.black38,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const Row(
                            children: [
                               Icon(Icons.lock_outline_rounded, size: 14, color: Color(0xFF7C4DFF)),
                               SizedBox(width: 4),
                               Text(
                                'Encrypted',
                                style: TextStyle(color: Color(0xFF7C4DFF), fontSize: 10, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getMoodColor(MoodType? mood) {
    switch (mood) {
      case MoodType.happy: return const Color(0xFFFFB74D);
      case MoodType.calm: return const Color(0xFF81C784);
      case MoodType.anxious: return const Color(0xFFFF7043);
      case MoodType.sad: return const Color(0xFF64B5F6);
      default: return const Color(0xFFBDBDBD);
    }
  }

  String _getMoodEmoji(MoodType? mood) {
    switch (mood) {
      case MoodType.happy: return '😊';
      case MoodType.calm: return '🍃';
      case MoodType.anxious: return '😰';
      case MoodType.sad: return '😢';
      default: return '😐';
    }
  }
}
