import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/journal_entry.dart';
import '../theme/app_theme.dart';
import 'neuro_card.dart';
import 'neuro_translate_button.dart';

class NeuroJournalCard extends StatefulWidget {
  const NeuroJournalCard({
    super.key,
    required this.entry,
    this.onTap,
  });

  final JournalEntry entry;
  final VoidCallback? onTap;

  @override
  State<NeuroJournalCard> createState() => _NeuroJournalCardState();
}

class _NeuroJournalCardState extends State<NeuroJournalCard> {
  late String _displayContent;

  @override
  void initState() {
    super.initState();
    _displayContent = widget.entry.content;
  }

  @override
  void didUpdateWidget(NeuroJournalCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.content != widget.entry.content) {
      _displayContent = widget.entry.content;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');
    final sentimentScore = widget.entry.sentimentScore;
    final isAnalyzed = sentimentScore != null;
    final hasMood = widget.entry.mood != null;
    
    return NeuroDashboardCard(
      title: widget.entry.title ?? dateFormat.format(widget.entry.createdAt),
      subtitle: widget.entry.title != null ? dateFormat.format(widget.entry.createdAt) : null,
      trailing: hasMood 
          ? Text(widget.entry.mood!.emoji, style: const TextStyle(fontSize: 20))
          : null,
      child: InkWell(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _displayContent,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: NeuroColors.onSurfaceVariant,
                    height: 1.5,
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
            if (isAnalyzed || hasMood) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (isAnalyzed)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getSentimentColor(sentimentScore).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getSentimentIcon(sentimentScore),
                            size: 14,
                            color: _getSentimentColor(sentimentScore),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getSentimentLabel(sentimentScore),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _getSentimentColor(sentimentScore),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (isAnalyzed && hasMood) const SizedBox(width: 8),
                  if (hasMood)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: NeuroColors.adolescentSurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.entry.mood!.label,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: NeuroColors.adolescentPrimary,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getSentimentColor(double score) {
    if (score >= 0.7) return Colors.green;
    if (score >= 0.4) return Colors.orange;
    return Colors.red;
  }

  String _getSentimentLabel(double score) {
    if (score >= 0.7) return 'Positive Vibes';
    if (score >= 0.4) return 'Neutral Vibes';
    return 'Negative Vibes';
  }

  IconData _getSentimentIcon(double score) {
    if (score >= 0.7) return Icons.sentiment_very_satisfied;
    if (score >= 0.4) return Icons.sentiment_neutral;
    return Icons.sentiment_very_dissatisfied;
  }
}
