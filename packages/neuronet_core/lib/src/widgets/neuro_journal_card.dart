import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/journal_entry.dart';
import '../theme/app_theme.dart';
import 'neuro_card.dart';

class NeuroJournalCard extends StatelessWidget {
  const NeuroJournalCard({
    super.key,
    required this.entry,
    this.onTap,
  });

  final JournalEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');
    final sentimentScore = entry.sentimentScore;
    final isAnalyzed = sentimentScore != null;
    final hasMood = entry.moodType != null;
    
    return NeuroDashboardCard(
      title: entry.title ?? dateFormat.format(entry.createdAt),
      subtitle: entry.title != null ? dateFormat.format(entry.createdAt) : null,
      trailing: hasMood 
          ? Text(entry.moodType!.emoji, style: const TextStyle(fontSize: 20))
          : null,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.content,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: NeuroColors.onSurfaceVariant,
                    height: 1.5,
                  ),
            ),
            if (isAnalyzed || hasMood) ...[
              const SizedBox(height: 16),
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
                        entry.moodType!.label,
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
