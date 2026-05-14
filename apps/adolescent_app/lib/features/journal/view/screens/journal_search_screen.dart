import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:neuronet_core/neuronet_core.dart';

import '../../../../config/router/app_router.dart';

/// Editorial-style search & filter screen for journal entries.

/// Safely formats a date with locale fallback.
String _safeFormatDate(DateTime date, String pattern, String locale) {
  try {
    return intl.DateFormat(pattern, locale).format(date);
  } on ArgumentError {
    return intl.DateFormat(pattern, 'en').format(date);
  }
}
class JournalSearchScreen extends StatefulWidget {
  final List<JournalEntry>? entries;
  final DateTime? initialDate;

  const JournalSearchScreen({super.key, this.entries, this.initialDate});

  @override
  State<JournalSearchScreen> createState() => _JournalSearchScreenState();
}

enum _DateFilter { all, today, thisWeek, specific }

class _JournalSearchScreenState extends State<JournalSearchScreen> {
  final _searchController = TextEditingController();
  final Set<String> _selectedEmotions = {};
  _DateFilter _dateFilter = _DateFilter.all;
  DateTime? _selectedSpecificDate;

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      _dateFilter = _DateFilter.specific;
      _selectedSpecificDate = widget.initialDate;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<JournalEntry> get _filteredEntries {
    final entries = widget.entries ?? [];
    return entries.where((entry) {
      // 1. Keyword search
      final query = _searchController.text.toLowerCase();
      final matchesQuery = query.isEmpty ||
          (entry.title?.toLowerCase().contains(query) ?? false) ||
          entry.content.toLowerCase().contains(query) ||
          (entry.mood?.localizedLabel(context.localizations).toLowerCase().contains(query) ?? false);

      if (!matchesQuery) return false;

      // 2. Emotion filter
      if (_selectedEmotions.isNotEmpty && !_selectedEmotions.contains(entry.emotion?.toLowerCase())) {
        return false;
      }

      // 3. Date filter
      final now = DateTime.now();
      final entryDate = entry.createdAt;
      switch (_dateFilter) {
        case _DateFilter.today:
          return entryDate.year == now.year &&
              entryDate.month == now.month &&
              entryDate.day == now.day;
        case _DateFilter.thisWeek:
          return entryDate.isAfter(now.subtract(const Duration(days: 7)));
        case _DateFilter.specific:
          if (_selectedSpecificDate == null) return true;
          return entryDate.year == _selectedSpecificDate!.year &&
              entryDate.month == _selectedSpecificDate!.month &&
              entryDate.day == _selectedSpecificDate!.day;
        case _DateFilter.all:
          return true;
      }
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredEntries;

    return Scaffold(
      backgroundColor: NeuroColors.paper,
      body: SafeArea(
        child: Column(
          children: [
            // Header & Search Input
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        context.localizations.discoverHeader,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          fontSize: 12,
                          color: NeuroColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: NeuroColors.hairline, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Hero(
                          tag: 'search_icon',
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: NeuroColors.hairline, width: 1.5),
                            ),
                            child: const Icon(Icons.search_rounded, size: 20, color: NeuroColors.ink),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: NeuroColors.ink,
                            ),
                            decoration: InputDecoration(
                              hintText: context.localizations.searchMemoriesHint,
                              hintStyle: const TextStyle(color: NeuroColors.inkMuted),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
_filterHeader(context.localizations.filterWhen),
                   const SizedBox(height: 12),
                   _dateFilterStrip(),
                   const SizedBox(height: 28),
                   _filterHeader(context.localizations.filterMood),
                   const SizedBox(height: 12),
                   _emotionFilterStrip(),
                  const SizedBox(height: 32),
                  _filterHeader(context.localizations.filterResults(results.length)),
                  const SizedBox(height: 12),
                  if (results.isEmpty) 
                    _emptyState() 
                  else 
                    ...List.generate(results.length, (index) {
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 400 + (index * 100)),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: _resultCard(results[index]),
                      );
                    }),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterHeader(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: 11,
        letterSpacing: 1.6,
        color: NeuroColors.inkMuted,
      ),
    );
  }

  Widget _dateFilterStrip() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterPill(context.localizations.filterAll, _dateFilter == _DateFilter.all, () => setState(() => _dateFilter = _DateFilter.all)),
          _filterPill(context.localizations.filterToday, _dateFilter == _DateFilter.today, () => setState(() => _dateFilter = _DateFilter.today)),
          _filterPill(context.localizations.filterThisWeek, _dateFilter == _DateFilter.thisWeek, () => setState(() => _dateFilter = _DateFilter.thisWeek)),
           if (_selectedSpecificDate != null)
             _filterPill(
               _safeFormatDate(_selectedSpecificDate!, 'd MMM', 'en'),
              _dateFilter == _DateFilter.specific,
              () => setState(() => _dateFilter = _DateFilter.specific),
            ),
        ],
      ),
    );
  }

  Widget _emotionFilterStrip() {
    final entries = widget.entries ?? [];
    final uniqueEmotions = entries
        .where((e) => e.emotion != null)
        .map((e) => e.emotion!.toLowerCase())
        .toSet()
        .toList()
      ..sort();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: uniqueEmotions.map((emotion) {
          final isSelected = _selectedEmotions.contains(emotion);
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() {
                if (isSelected) {
                  _selectedEmotions.remove(emotion);
                } else {
                  _selectedEmotions.add(emotion);
                }
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? NeuroColors.ink : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: isSelected ? NeuroColors.ink : NeuroColors.hairline, width: 1.5),
                ),
                child: Text(_getEmotionEmoji(emotion), style: const TextStyle(fontSize: 20)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _filterPill(String label, bool active, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: active ? NeuroColors.ink : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: active ? NeuroColors.ink : NeuroColors.hairline, width: 1.5),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: active ? Colors.white : NeuroColors.inkSoft,
            ),
          ),
        ),
      ),
    );
  }

  Widget _resultCard(JournalEntry entry) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push('${AdolescentRoutes.journal}/${entry.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: NeuroColors.hairline, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                 Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _moodToColor(entry.mood),
                    shape: BoxShape.circle,
                  ),
                ),
                 const SizedBox(width: 8),
                 Text(
                   _safeFormatDate(entry.createdAt, 'd MMM, h:mm a', 'en'),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: NeuroColors.inkMuted),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (entry.title != null) ...[
              Text(
                entry.title!,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: NeuroColors.ink),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              entry.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, height: 1.5, color: NeuroColors.inkSoft),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
     return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded, size: 48, color: NeuroColors.hairline),
            const SizedBox(height: 16),
            Text(
              context.localizations.stillLooking,
              style: const TextStyle(fontWeight: FontWeight.w900, color: NeuroColors.inkMuted),
            ),
          ],
        ),
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

  String _getEmotionEmoji(String emotion) {
    final label = emotion.toLowerCase();
    if (label.contains('happy') || label.contains('joy') || label.contains('positive')) return '😊';
    if (label.contains('sad') || label.contains('grief') || label.contains('negative')) return '😢';
    if (label.contains('anxious') || label.contains('anxiety') || label.contains('worry')) return '😰';
    if (label.contains('calm') || label.contains('peace') || label.contains('relaxed')) return '🍃';
    if (label.contains('stress') || label.contains('stressed')) return '😫';
    if (label.contains('angry') || label.contains('anger') || label.contains('mad')) return '😠';
    if (label.contains('excited') || label.contains('excitement')) return '✨';
    if (label.contains('tired') || label.contains('fatigue') || label.contains('exhaust')) return '😴';
    if (label.contains('hope') || label.contains('hopeful')) return '🌈';
    if (label.contains('fear') || label.contains('afraid') || label.contains('scared')) return '😨';
    if (label.contains('surprise') || label.contains('surprised')) return '😮';
    if (label.contains('disgust') || label.contains('disgusted')) return '🤢';
    return '😐';
  }
}
