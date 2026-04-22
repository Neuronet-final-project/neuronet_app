import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:intl/intl.dart';
import '../../providers/journal_provider.dart';

class JournalDetailScreen extends ConsumerWidget {
  const JournalDetailScreen({super.key, required this.entryId});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalAsync = ref.watch(journalControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: journalAsync.when(
        data: (state) {
          final entry = state.entries.firstWhere(
            (e) => e.id == entryId,
            orElse: () => throw Exception('Entry not found'),
          );

          return _DetailContent(entry: entry);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.entry});
  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final wordCount = entry.content.split(' ').where((s) => s.isNotEmpty).length;
    final readTime = (wordCount / 200).ceil();
    final moodColor = _getMoodColor(entry.mood);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 240,
          pinned: true,
          elevation: 0,
          backgroundColor: const Color(0xFF7C4DFF),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.2)),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined, color: Colors.white),
              onPressed: () {},
              style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.2)),
            ),
            IconButton(
              icon: const Icon(Icons.more_horiz_rounded, color: Colors.white),
              onPressed: () {},
              style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.2)),
            ),
            const SizedBox(width: 8),
          ],
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
                padding: EdgeInsets.fromLTRB(32, MediaQuery.of(context).padding.top + 60, 32, 0),
                child: Row(
                  children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                        ),
                        child: Text(_getMoodEmoji(entry.mood), style: const TextStyle(fontSize: 48)),
                      ),
                      const SizedBox(width: 24),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE').format(entry.createdAt).toUpperCase(),
                            style: const TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2),
                          ),
                          Text(
                            DateFormat('MMMM d, y').format(entry.createdAt),
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.access_time_filled_rounded, color: Colors.white70, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('h:mm a').format(entry.createdAt),
                                style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ),
        ),
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: const Offset(0, -20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatItem(
                          icon: Icons.circle,
                          iconColor: moodColor,
                          label: entry.mood?.name.toUpperCase() ?? 'NEUTRAL',
                        ),
                        Container(width: 1, height: 20, color: Colors.black12),
                        _StatItem(
                          icon: Icons.title_rounded,
                          label: '$wordCount words',
                        ),
                        Container(width: 1, height: 20, color: Colors.black12),
                        _StatItem(
                          icon: Icons.menu_book_rounded,
                          label: '$readTime min read',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    entry.title ?? 'Untitled Entry',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C4DFF).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          entry.content,
                          style: const TextStyle(
                            fontSize: 17,
                            height: 1.8,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(0xFF7C4DFF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.shield_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 20),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'End-to-End Encrypted',
                              style: TextStyle(color: Color(0xFF7C4DFF), fontWeight: FontWeight.w900, fontSize: 16),
                            ),
                            Text(
                              'Only you can read this entry. Always.',
                              style: TextStyle(color: Colors.black45, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ],
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

class _StatItem extends StatelessWidget {
  const _StatItem({required this.icon, required this.label, this.iconColor = const Color(0xFF7C4DFF)});
  final IconData icon;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 14),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF475569), fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
