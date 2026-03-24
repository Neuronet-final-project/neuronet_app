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
    final isAnalyzed = entry.sentimentScore != null;
    
    return NeuroDashboardCard(
      title: dateFormat.format(entry.createdAt),
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
            if (isAnalyzed) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getSentimentColor(entry.sentimentScore!).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getSentimentIcon(entry.sentimentScore!),
                          size: 14,
                          color: _getSentimentColor(entry.sentimentScore!),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getSentimentLabel(entry.sentimentScore!),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _getSentimentColor(entry.sentimentScore!),
                          ),
                        ),
                      ],
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
    if (score >= 0.7) return 'Positive Mood';
    if (score >= 0.4) return 'Neutral Mood';
    return 'Negative Mood';
  }

  IconData _getSentimentIcon(double score) {
    if (score >= 0.7) return Icons.sentiment_very_satisfied;
    if (score >= 0.4) return Icons.sentiment_neutral;
    return Icons.sentiment_very_dissatisfied;
  }
}
