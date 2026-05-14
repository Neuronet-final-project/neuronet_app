import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../providers/mood_provider.dart';

class MoodHistoryScreen extends ConsumerWidget {
  const MoodHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(moodHistoryControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9FF),
      body: Stack(
        children: [
          // Background Gradients
          Positioned.fill(
            child: Stack(
              children: [
                Container(color: const Color(0xFFFBF9FF)),
                Positioned(
                  top: -50,
                  right: -50,
                  child: Icon(Icons.circle, size: 300, color: const Color(0xFFD8C2FF).withOpacity(0.15)),
                ),
              ],
            ),
          ),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(context, ref, historyAsync),
              historyAsync.when(
                data: (state) {
                  if (state.records.isEmpty && !state.isLoading) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'No mood check-ins yet',
                          style: const TextStyle(color: Color(0xFFB4A8D3), fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  }

                  // Group records by day
                  final grouped = _groupRecordsByDay(state.records);

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final dayGroup = grouped[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 32, bottom: 20, left: 4),
                                child: Text(
                                  _formatGroupHeader(dayGroup.date, context).toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF6A1FDB),
                                    letterSpacing: 2.0,
                                  ),
                                ),
                              ),
                              ...dayGroup.records.map((r) => _buildMoodCard(context, r)),
                            ],
                          );
                        },
                        childCount: grouped.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF6A1FDB))),
                ),
                error: (err, _) => SliverFillRemaining(
                  child: Center(
                    child: NeuroErrorWidget(
                      message: err.toString(),
                      onRetry: () => ref.read(moodHistoryControllerProvider.notifier).refresh(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (historyAsync.value?.isLoading ?? false)
            const Positioned(
              top: 0, left: 0, right: 0,
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6A1FDB)),
                minHeight: 2,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, WidgetRef ref, AsyncValue<MoodHistoryState> historyAsync) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: const Color(0xFFFBF9FF).withValues(alpha: 0.8),
      elevation: 0,
      centerTitle: true,
      leadingWidth: 70,
      leading: Center(
        child: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6A1FDB).withValues(alpha: 0.08),
                blurRadius: 10, offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 20, color: Color(0xFF1A123D)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      title: const Text(
        'Past Check-Ins',
        style: TextStyle(
          color: Color(0xFF1A123D),
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6A1FDB).withValues(alpha: 0.08),
                    blurRadius: 10, offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: historyAsync.value?.isLoading ?? false
                ? const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6A1FDB))))
                : IconButton(
                    icon: const Icon(Icons.refresh_rounded, size: 20, color: Color(0xFF6A1FDB)),
                    onPressed: () => ref.read(moodHistoryControllerProvider.notifier).refresh(),
                  ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoodCard(BuildContext context, MoodRecord r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF6A1FDB).withValues(alpha: 0.04)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A1FDB).withValues(alpha: 0.03),
            blurRadius: 16, offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getMoodColor(r.mood).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(r.mood.emoji, style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      r.mood.localizedLabel(context.localizations).toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: _getMoodColor(r.mood),
                        letterSpacing: 1.2,
                      ),
                    ),
                    if (r.intensity != null) ...[
                      const SizedBox(width: 8),
                      Container(width: 3, height: 3, decoration: const BoxDecoration(color: Color(0xFFB4A8D3), shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text(
                        '${context.localizations.levelAbbr} ${r.intensity}'.toUpperCase(),
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFB4A8D3), letterSpacing: 0.5),
                      ),
                    ]
                  ],
                ),
                const SizedBox(height: 6),
                if (r.note != null && r.note!.isNotEmpty) ...[
                  Text(
                    r.note!,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A123D),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 12, color: const Color(0xFFB4A8D3).withValues(alpha: 0.8)),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(r.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFB4A8D3),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    // CRITICAL: Force treat server time as UTC if it's not marked as such.
    final serverTime = dt.isUtc 
        ? dt 
        : DateTime.utc(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second, dt.millisecond, dt.microsecond);
    return DateFormat('h:mm a').format(serverTime.toLocal());
  }

  String _formatGroupHeader(DateTime date, BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) return 'Today'.toUpperCase();
    if (checkDate == yesterday) return 'Yesterday'.toUpperCase();
    return DateFormat('MMMM d, y').format(date).toUpperCase();
  }

  List<_DayGroup> _groupRecordsByDay(List<MoodRecord> records) {
    final groups = <DateTime, List<MoodRecord>>{};
    for (final r in records) {
      final date = DateTime(r.createdAt.year, r.createdAt.month, r.createdAt.day);
      if (!groups.containsKey(date)) {
        groups[date] = [];
      }
      groups[date]!.add(r);
    }

    final result = groups.entries
        .map((e) => _DayGroup(date: e.key, records: e.value))
        .toList();
    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  Color _getMoodColor(MoodType mood) {
    switch (mood) {
      case MoodType.happy: return const Color(0xFFFFA726);
      case MoodType.calm: return const Color(0xFF66BB6A);
      case MoodType.anxious: return const Color(0xFFFF7043);
      case MoodType.sad: return const Color(0xFF42A5F5);
      case MoodType.hopeful: return const Color(0xFFAB47BC);
      case MoodType.excited: return const Color(0xFFEC407A);
      case MoodType.tired: return const Color(0xFF7E57C2);
      case MoodType.angry: return const Color(0xFFEF5350);
      default: return NeuroColors.adolescentPrimary;
    }
  }
}

class _DayGroup {
  final DateTime date;
  final List<MoodRecord> records;
  _DayGroup({required this.date, required this.records});
}
