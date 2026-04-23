import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../../../config/router/app_router.dart';
import '../../providers/journal_provider.dart';

/// Minimalist Journal History Redesign
/// - Timeless, minimalist aesthetic (Editorial Paper & Ink)
/// - Grouped by day with large date indicators
/// - "Activity" horizontal card with mood tracking
/// - Centered "Compose" FAB
class JournalHistoryScreen extends ConsumerStatefulWidget {
  const JournalHistoryScreen({super.key});

  @override
  ConsumerState<JournalHistoryScreen> createState() =>
      _JournalHistoryScreenState();
}

class _JournalHistoryScreenState extends ConsumerState<JournalHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final journalAsync = ref.watch(journalControllerProvider);

    return Scaffold(
      backgroundColor: NeuroColors.paper,
      body: Stack(
        children: [
          // Subtle Paper Grain Texture
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: CustomPaint(painter: _PaperGrainPainter()),
            ),
          ),
          RefreshIndicator(
            color: NeuroColors.adolescentPrimary,
            onRefresh: () => ref.read(journalControllerProvider.notifier).refresh(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // 1. Minimalist Top Header
                const _MinimalistHeader(),

                // 2. Weekly Stats Card
                journalAsync.maybeWhen(
                  data: (state) => SliverToBoxAdapter(
                    child: _WeeklyStatsCard(entries: state.entries),
                  ),
                  orElse: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                ),

                // 3. Grouped Entry List
                journalAsync.when(
                  data: (state) => _buildGroupedList(context, state.entries),
                  loading: () => SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, __) => const Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
                        child: NeuroSkeletonCard(),
                      ),
                      childCount: 4,
                    ),
                  ),
                  error: (err, _) => SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: NeuroErrorWidget(
                        message: 'Error loading journals: $err',
                        onRetry: () =>
                            ref.read(journalControllerProvider.notifier).refresh(),
                      ),
                    ),
                  ),
                ),

                const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _ComposeFAB(
        onPressed: () => context.push(AdolescentRoutes.newJournal),
      ),
    );
  }

  Widget _buildGroupedList(BuildContext context, List<JournalEntry> entries) {
    if (entries.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: NeuroColors.adolescentPrimary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.history_edu_rounded,
                  size: 64,
                  color: NeuroColors.adolescentPrimary,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'No memories yet',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: NeuroColors.ink,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Start writing your story today.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: NeuroColors.inkMuted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Group entries by day
    final Map<DateTime, List<JournalEntry>> groups = {};
    for (final entry in entries) {
      final date = DateTime(
        entry.createdAt.year,
        entry.createdAt.month,
        entry.createdAt.day,
      );
      groups.putIfAbsent(date, () => []).add(entry);
    }

    final sortedDates = groups.keys.toList()..sort((a, b) => b.compareTo(a));

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final date = sortedDates[index];
          final dayEntries = groups[date]!;
          return _DayGroup(date: date, entries: dayEntries);
        },
        childCount: sortedDates.length,
      ),
    );
  }
}

class _MinimalistHeader extends StatelessWidget {
  const _MinimalistHeader();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthYear = DateFormat('MMMM yyyy').format(now);

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          MediaQuery.of(context).padding.top + 20,
          24,
          24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'JOURNAL',
              style: TextStyle(
                color: NeuroColors.adolescentPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.4,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  monthYear,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: NeuroColors.ink,
                    letterSpacing: -0.8,
                  ),
                ),
                Row(
                  children: [
                    Hero(
                      tag: 'search_icon',
                      child: _RoundActionIcon(
                        icon: Icons.search_rounded,
                        onTap: () => context.push(AdolescentRoutes.searchJournal),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _RoundActionIcon(
                      icon: Icons.calendar_today_rounded,
                      onTap: () => _showCalendarPicker(context),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCalendarPicker(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: NeuroColors.adolescentPrimary,
              onPrimary: Colors.white,
              onSurface: NeuroColors.ink,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: NeuroColors.adolescentPrimary,
                textStyle: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && context.mounted) {
      context.push(AdolescentRoutes.searchJournal, extra: picked);
    }
  }
}

class _RoundActionIcon extends StatelessWidget {
  const _RoundActionIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: NeuroColors.hairline, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: NeuroColors.ink, size: 20),
          ),
        ),
      ),
    );
  }
}

class _WeeklyStatsCard extends StatelessWidget {
  const _WeeklyStatsCard({required this.entries});
  final List<JournalEntry> entries;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekDays = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));
    
    final weekRangeStart = weekDays.first;
    final entriesThisWeek = entries.where((e) => e.createdAt.isAfter(weekRangeStart)).toList();
    final entriesThisWeekCount = entriesThisWeek.length;
    
    // Map weekday to mood color if entry exists
    final Map<int, Color> dayEntryMap = {};
    for (final day in weekDays) {
      final dayEntries = entries.where((e) => 
        e.createdAt.day == day.day && 
        e.createdAt.month == day.month && 
        e.createdAt.year == day.year
      );
      if (dayEntries.isNotEmpty) {
        dayEntryMap[day.weekday] = _moodToColor(dayEntries.first.mood);
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: NeuroColors.hairline, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ACTIVITY',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 1.6,
                  color: NeuroColors.inkMuted,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: NeuroColors.adolescentPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$entriesThisWeekCount MEMORIES',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    color: NeuroColors.adolescentPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekDays.map((day) {
              final color = dayEntryMap[day.weekday];
              final isToday = day.day == today.day && 
                             day.month == today.month && 
                             day.year == today.year;
              
              return Column(
                children: [
                  Text(
                    DateFormat('E').format(day).substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isToday ? FontWeight.w900 : FontWeight.w700,
                      color: isToday ? NeuroColors.ink : NeuroColors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isToday) 
                        _PulseCircle(color: color ?? NeuroColors.adolescentPrimary),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color ?? Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isToday ? (color ?? NeuroColors.ink) : NeuroColors.hairline,
                            width: isToday ? 2 : 1.5,
                          ),
                          boxShadow: color != null ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ] : null,
                        ),
                        child: color != null ? const Icon(Icons.check_rounded, size: 16, color: Colors.white) : null,
                      ),
                    ],
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color _moodToColor(MoodType? mood) {
    if (mood == null) return NeuroColors.adolescentPrimary;
    final label = mood.label.toLowerCase();
    if (label.contains('happy')) return NeuroColors.moodHappy;
    if (label.contains('sad')) return NeuroColors.moodSad;
    if (label.contains('anxious')) return NeuroColors.moodAnxious;
    if (label.contains('calm')) return NeuroColors.moodCalm;
    if (label.contains('stress')) return NeuroColors.moodStressed;
    if (label.contains('excit')) return NeuroColors.moodExcited;
    if (label.contains('tired')) return NeuroColors.moodTired;
    if (label.contains('angry')) return NeuroColors.moodAngry;
    if (label.contains('hope')) return NeuroColors.moodHopeful;
    return NeuroColors.adolescentPrimary;
  }
}

class _DayGroup extends StatelessWidget {
  const _DayGroup({required this.date, required this.entries});
  final DateTime date;
  final List<JournalEntry> entries;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday = date.day == now.day && date.month == now.month && date.year == now.year;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                DateFormat('d').format(date),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: NeuroColors.ink,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE').format(date).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: NeuroColors.ink,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    DateFormat('MMM yyyy').format(date).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: NeuroColors.inkMuted,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              if (isToday) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: NeuroColors.ink,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'TODAY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          ...entries.map((entry) => _EntryCard(entry: entry)),
        ],
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry});
  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('${AdolescentRoutes.journal}/${entry.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: NeuroColors.hairline, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _MoodDot(mood: entry.mood),
                const SizedBox(width: 8),
                Text(
                  DateFormat('h:mm a').format(entry.createdAt),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: NeuroColors.inkMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (entry.title != null) ...[
              Text(
                entry.title!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: NeuroColors.ink,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              entry.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: NeuroColors.inkSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodDot extends StatelessWidget {
  const _MoodDot({required this.mood});
  final MoodType? mood;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: _getColor(mood),
        shape: BoxShape.circle,
      ),
    );
  }

  Color _getColor(MoodType? mood) {
    if (mood == null) return NeuroColors.adolescentPrimary;
    final label = mood.label.toLowerCase();
    if (label.contains('happy')) return NeuroColors.moodHappy;
    if (label.contains('sad')) return NeuroColors.moodSad;
    if (label.contains('anxious')) return NeuroColors.moodAnxious;
    if (label.contains('calm')) return NeuroColors.moodCalm;
    if (label.contains('stress')) return NeuroColors.moodStressed;
    if (label.contains('excit')) return NeuroColors.moodExcited;
    if (label.contains('tired')) return NeuroColors.moodTired;
    if (label.contains('angry')) return NeuroColors.moodAngry;
    if (label.contains('hope')) return NeuroColors.moodHopeful;
    return NeuroColors.adolescentPrimary;
  }
}

class _ComposeFAB extends StatelessWidget {
  const _ComposeFAB({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: NeuroColors.ink.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.edit_document, size: 20),
        label: const Text(
          'Compose',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: NeuroColors.ink,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
    );
  }
}

class _PulseCircle extends StatefulWidget {
  final Color color;
  const _PulseCircle({required this.color});

  @override
  State<_PulseCircle> createState() => _PulseCircleState();
}

class _PulseCircleState extends State<_PulseCircle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 32 + (16 * _controller.value),
          height: 32 + (16 * _controller.value),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.color.withValues(alpha: 1 - _controller.value),
              width: 1.5,
            ),
          ),
        );
      },
    );
  }
}

class _PaperGrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = NeuroColors.ink;
    final random = math.Random(42);
    for (var i = 0; i < 2000; i++) {
       canvas.drawCircle(
         Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
         0.5,
         paint,
       );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
