import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../l10n.dart';

class NeuroTrendChart extends StatelessWidget {
  final List<dynamic> trends;
  final bool showDots;
  final Color? lineColor;

  const NeuroTrendChart({
    super.key,
    required this.trends,
    this.showDots = false,
    this.lineColor,
  });

  @override
  Widget build(BuildContext context) {
    if (trends.isEmpty) {
      return Center(child: Text(context.localizations.insufficientData));
    }

    final effectiveColor = lineColor ?? Theme.of(context).primaryColor;

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: trends.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.sentimentScore as double);
            }).toList(),
            isCurved: true,
            color: effectiveColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: showDots),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  effectiveColor.withValues(alpha: 0.2),
                  effectiveColor.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
