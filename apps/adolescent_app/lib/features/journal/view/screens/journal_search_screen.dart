import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neuronet_core/neuronet_core.dart';

/// Editorial-style search & filter screen for journal entries.
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
  final Set<MoodType> _selectedMoods = {};
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
          entry.content.toLowerCase().contains(query);

      if (!matchesQuery) return false;

      // 2. Mood filter
      if (_selectedMoods.isNotEmpty && !_selectedMoods.contains(entry.mood)) {
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
        default:
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
                  _moodFilterStrip(),
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
              DateFormat('d MMM').format(_selectedSpecificDate!),
              _dateFilter == _DateFilter.specific,
              () => setState(() => _dateFilter = _DateFilter.specific),
            ),
        ],
      ),
    );
  }

  Widget _moodFilterStrip() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: MoodType.values.map((mood) {
          final isSelected = _selectedMoods.contains(mood);
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() {
                if (isSelected) _selectedMoods.remove(mood);
                else _selectedMoods.add(mood);
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? NeuroColors.ink : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: isSelected ? NeuroColors.ink : NeuroColors.hairline, width: 1.5),
                ),
                child: Text(_getMoodEmoji(mood), style: const TextStyle(fontSize: 20)),
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
      onTap: () => Navigator.pop(context), // Normally would navigate to detail
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
                  DateFormat('d MMM, h:mm a').format(entry.createdAt),
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

  String _getMoodEmoji(MoodType mood) {
    switch (mood) {
      case MoodType.happy: return '😊';
      case MoodType.calm: return '🍃';
      case MoodType.hopeful: return '🌈';
      case MoodType.excited: return '✨';
      case MoodType.anxious: return '😰';
      case MoodType.sad: return '😢';
      case MoodType.stressed: return '😫';
      case MoodType.angry: return '😠';
      case MoodType.tired: return '😴';
      default: return '😐';
    }
  }
}
