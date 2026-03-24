import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/dashboard.dart';
import '../theme/app_theme.dart';

class NeuroTrendChart extends StatelessWidget {
  const NeuroTrendChart({
    super.key,
    required this.trends,
    this.showDots = true,
  });

  final List<EmotionalTrend> trends;
  final bool showDots;

  @override
  Widget build(BuildContext context) {
    if (trends.isEmpty) {
      return const Center(child: Text('No trend data available'));
    }

    final colorScheme = Theme.of(context).colorScheme;

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= trends.length) return const SizedBox.shrink();
                
                // Show title only for first, middle, and last points to avoid crowding
                if (index != 0 && index != (trends.length / 2).floor() && index != trends.length - 1) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('E').format(trends[index].date),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: NeuroColors.onSurfaceVariant,
                        ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: trends.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.sentimentScore);
            }).toList(),
            isCurved: true,
            color: colorScheme.primary,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(show: showDots),
            belowBarData: BarAreaData(
              show: true,
              color: colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final trend = trends[spot.spotIndex];
                return LineTooltipItem(
                  '${DateFormat('MMM d').format(trend.date)}\nScore: ${(trend.sentimentScore * 100).toStringAsFixed(0)}%',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
