import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:neuronet_core/neuronet_core.dart';
import '../../../../config/router/app_router.dart';
import '../../providers/journal_provider.dart';

/// Safely formats a date with locale fallback.
/// Falls back to English if the current locale is not supported by intl.
String _safeFormatDate(DateTime date, String pattern, String locale) {
  try {
    return intl.DateFormat(pattern, locale).format(date);
  } on ArgumentError {
    return intl.DateFormat(pattern, 'en').format(date);
  }
}

/// Premium Purple Theme Journal History
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

    ref.listen<String?>(journalBackgroundSaveErrorProvider, (previous, next) {
      if (next == null || next.isEmpty) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(journalBackgroundSaveErrorProvider.notifier).clear();
      });
    });

    return Scaffold(
      backgroundColor: NeuroColors.adolescentSurface,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFF3EEFF),
                    NeuroColors.adolescentSurface,
                    const Color(0xFFE8E0F8).withValues(alpha: 0.35),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: RefreshIndicator(
              color: NeuroColors.adolescentPrimary,
              backgroundColor: Colors.white,
              onRefresh: () => ref.read(journalControllerProvider.notifier).refresh(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
            // 1. Premium Header
            _JournalHeader(
              onRefresh: () => ref.read(journalControllerProvider.notifier).refresh(),
            ),

            // 2. Weekly Activity Card
            journalAsync.maybeWhen(
              data: (state) => SliverToBoxAdapter(
                child: _WeeklyActivityCard(entries: state.entries),
              ),
              orElse: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),

             // 3. Entries List
             journalAsync.when(
               data: (state) => _buildGroupedList(context, state.entries),
               loading: () => SliverList(
                 delegate: SliverChildBuilderDelegate(
                   (_, __) => const Padding(
                     padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
                     child: _JournalEntrySkeleton(),
                   ),
                   childCount: 4,
                 ),
               ),
               error: (err, _) => SliverToBoxAdapter(
                 child: Padding(
                   padding: const EdgeInsets.all(24),
                   child: NeuroErrorWidget(
                     message: '${context.localizations.failedToLoadJournals}: $err',
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        NeuroColors.adolescentSurfaceVariant,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      NeuroShadows.adolescentGlow,
                      BoxShadow(
                        color: NeuroColors.adolescentPrimary.withValues(alpha: 0.1),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                    ],
                    border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 2),
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    size: 56,
                    color: NeuroColors.adolescentPrimary,
                  ),
                ),
                const SizedBox(height: 28),
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF6A1FDB), Color(0xFF9E7AFF)],
                  ).createShader(bounds),
                  child: Text(
                    context.localizations.yourJournalAwaits,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  context.localizations.captureHowYouFeel,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6A5C9A),
                  ),
                ),
              ],
            ),
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

class _JournalHeader extends StatelessWidget {
  const _JournalHeader({required this.onRefresh});
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthYear = _safeFormatDate(now, 'yMMMM', context.localizations.localeName);

    return SliverAppBar(
      expandedHeight: 152,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              right: -30,
              top: MediaQuery.of(context).padding.top - 10,
              child: Icon(Icons.circle, size: 120, color: NeuroColors.adolescentPrimary.withValues(alpha: 0.06)),
            ),
            Positioned(
              left: -20,
              bottom: 8,
              child: Icon(Icons.circle, size: 80, color: const Color(0xFF9E7AFF).withValues(alpha: 0.08)),
            ),
            Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            MediaQuery.of(context).padding.top + 20,
            24,
            16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: NeuroGradients.adolescent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  context.localizations.secureJournalTag,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    monthYear,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2C1C5F),
                      letterSpacing: -0.8,
                    ),
                  ),
                ],
              ),
            ],
          ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Row(
            children: [
              Hero(
                tag: 'search_icon',
                child: _HeaderIcon(
                  icon: Icons.search_rounded,
                  onTap: () => context.push(AdolescentRoutes.searchJournal),
                ),
              ),
              const SizedBox(width: 8),
              _HeaderIcon(
                icon: Icons.calendar_month_rounded,
                onTap: () => _showCalendarPicker(context),
              ),
              const SizedBox(width: 8),
              _HeaderIcon(
                icon: Icons.refresh_rounded,
                onTap: () {
                  onRefresh();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.localizations.refreshingJournal),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ],
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
              onSurface: Color(0xFF2C1C5F),
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

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: NeuroColors.adolescentPrimary.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: NeuroColors.adolescentPrimary, size: 22),
      ),
    );
  }
}

class _WeeklyActivityCard extends StatelessWidget {
  const _WeeklyActivityCard({required this.entries});
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
        dayEntryMap[day.weekday] = _getMoodColor(dayEntries.first.mood);
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: NeuroGradients.adolescentCard,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.55), width: 1.2),
        boxShadow: [
          NeuroShadows.adolescentGlow,
          BoxShadow(
            color: NeuroColors.adolescentPrimary.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.localizations.thisWeek,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.6,
                  color: Color(0xFF6A5C9A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: NeuroColors.adolescentPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  context.localizations.memoriesCount(entriesThisWeekCount),
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
                     _safeFormatDate(day, 'E', context.localizations.localeName).substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.w900 : FontWeight.w700,
                      color: isToday ? NeuroColors.adolescentPrimary : const Color(0xFF8A7DAC),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: color ?? Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isToday 
                            ? NeuroColors.adolescentPrimary 
                            : (color ?? const Color(0xFFE0DAF0)),
                        width: isToday ? 2.5 : 1.0,
                      ),
                      boxShadow: color != null ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ] : null,
                    ),
                    child: color != null 
                        ? const Icon(Icons.check_rounded, size: 18, color: Colors.white) 
                        : null,
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color _getMoodColor(MoodType? mood) {
    switch (mood) {
      case MoodType.happy: return const Color(0xFFFFB74D);
      case MoodType.calm: return const Color(0xFF81C784);
      case MoodType.anxious: return const Color(0xFFFF7043);
      case MoodType.sad: return const Color(0xFF64B5F6);
      default: return NeuroColors.adolescentPrimary;
    }
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: isToday ? NeuroGradients.adolescent : null,
                  color: isToday ? null : NeuroColors.adolescentSurfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isToday ? Colors.white.withValues(alpha: 0.35) : const Color(0xFFE0DAF0),
                    width: isToday ? 1.5 : 1,
                  ),
                  boxShadow: isToday
                      ? [NeuroShadows.adolescentGlow, BoxShadow(color: const Color(0xFF5A1BC7).withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4))]
                      : null,
                ),
                 child: Center(
                   child: Text(
                     _safeFormatDate(date, 'd', context.localizations.localeName),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isToday ? Colors.white : NeuroColors.adolescentPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(
                     isToday ? context.localizations.today : _safeFormatDate(date, 'EEEE', context.localizations.localeName).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2C1C5F),
                      letterSpacing: 1.2,
                    ),
                  ),
                   Text(
                     _safeFormatDate(date, 'yMMM', context.localizations.localeName).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8A7DAC),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...entries.map((entry) => _EntryCard(entry: entry, isPendingSync: entry.id.startsWith('pending-'))),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _EntryCard extends StatefulWidget {
  const _EntryCard({required this.entry, this.isPendingSync = false});
  final JournalEntry entry;
  final bool isPendingSync;

  @override
  State<_EntryCard> createState() => _EntryCardState();
}

class _EntryCardState extends State<_EntryCard> {
  late String _displayContent;

  @override
  void initState() {
    super.initState();
    _displayContent = widget.entry.content;
  }

  @override
  void didUpdateWidget(_EntryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.content != widget.entry.content) {
      _displayContent = widget.entry.content;
    }
  }

  Color _accent(MoodType? mood) {
    return switch (mood) {
      MoodType.happy => const Color(0xFFFFB74D),
      MoodType.calm => const Color(0xFF66BB6A),
      MoodType.anxious => const Color(0xFFFF7043),
      MoodType.sad => const Color(0xFF42A5F5),
      MoodType.hopeful => const Color(0xFFAB47BC),
      MoodType.excited => const Color(0xFFEC407A),
      MoodType.tired => const Color(0xFF7E57C2),
      MoodType.angry => const Color(0xFFEF5350),
      MoodType.stressed => const Color(0xFFFF8A65),
      MoodType.neutral => NeuroColors.adolescentPrimary,
      null => NeuroColors.adolescentPrimary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accent(widget.entry.mood);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.isPendingSync
             ? () {
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                     content: Text(context.localizations.stillSyncingEntry),
                     behavior: SnackBarBehavior.floating,
                   ),
                 );
               }              : () => context.push('${AdolescentRoutes.journal}/${widget.entry.id}'),
          borderRadius: BorderRadius.circular(22),
          splashColor: NeuroColors.adolescentPrimary.withValues(alpha: 0.08),
          highlightColor: NeuroColors.adolescentPrimary.withValues(alpha: 0.04),
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE8E0F0), width: 1),
              boxShadow: [
                BoxShadow(
                  color: NeuroColors.adolescentPrimary.withValues(alpha: 0.07),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 4,
                  child: ColoredBox(color: accent),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _MoodBadge(mood: widget.entry.mood),
                          if (widget.isPendingSync) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: NeuroColors.adolescentPrimary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                context.localizations.syncingTag,
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.6,
                                  color: NeuroColors.adolescentPrimary,
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                           const Icon(Icons.access_time_rounded, size: 12, color: Color(0xFF8A7DAC)),
                           const SizedBox(width: 4),
                           Text(
                             _safeFormatDate(widget.entry.createdAt, 'jm', context.localizations.localeName),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF8A7DAC),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (widget.entry.title != null) ...[
                        Text(
                          widget.entry.title!,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2C1C5F),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                      Text(
                        _displayContent,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Color(0xFF53477D),
                        ),
                      ),
                      const SizedBox(height: 8),
                      NeuroTranslateButton(
                        text: widget.entry.content,
                        onTranslationDone: (translated, isOriginal) {
                          setState(() {
                            _displayContent = translated;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MoodBadge extends StatelessWidget {
  const _MoodBadge({required this.mood});
  final MoodType? mood;

  @override
  Widget build(BuildContext context) {
    if (mood == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getMoodColor(mood).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_getMoodEmoji(mood), style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            mood!.localizedLabel(context.localizations).toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: _getMoodColor(mood),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Color _getMoodColor(MoodType? mood) {
    switch (mood) {
      case MoodType.happy: return const Color(0xFFE65100);
      case MoodType.calm: return const Color(0xFF2E7D32);
      case MoodType.anxious: return const Color(0xFFD84315);
      case MoodType.sad: return const Color(0xFF1565C0);
      default: return NeuroColors.adolescentPrimaryDark;
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

class _ComposeFAB extends StatelessWidget {
  const _ComposeFAB({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          NeuroShadows.adolescentGlow,
          BoxShadow(
            color: const Color(0xFF5A1BC7).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: NeuroGradients.adolescent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.5),
        ),
        child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.edit_document, size: 20),
        label: Text(
          context.localizations.composeEntry,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 28),
           shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(30),
           ),
         ),
       ),
       ),
     );
   }
 }

// ── Journal Entry Skeleton ─────────────────────────────────────────────────────
class _JournalEntrySkeleton extends StatelessWidget {
  const _JournalEntrySkeleton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 18, 18, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE8E0F0), width: 1),
          boxShadow: [
            BoxShadow(
              color: NeuroColors.adolescentPrimary.withValues(alpha: 0.07),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left accent strip placeholder
            NeuroShimmer(
              child: Container(
                width: 4,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Date badge placeholder
            NeuroShimmer(
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: mood badge + time
                  Row(
                    children: [
                      // Mood badge placeholder
                      NeuroShimmer(
                        child: Container(
                          width: 50,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Time placeholder
                      NeuroShimmer(
                        child: Container(
                          width: 50,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Title placeholder
                  NeuroShimmer(
                    child: Container(
                      width: double.infinity,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Content placeholder (two lines)
                  NeuroShimmer(
                    child: Container(
                      width: double.infinity,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  NeuroShimmer(
                    child: Container(
                      width: 180,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
