import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';

class NeuroTrendChart extends StatelessWidget {
  final List<dynamic> trends;
  final bool showDots;

  const NeuroTrendChart({
    super.key,
    required this.trends,
    this.showDots = false,
  });

  @override
  Widget build(BuildContext context) {
    if (trends.isEmpty) {
      return const Center(child: Text('Insufficient data for analysis.'));
    }

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
            color: NeuroColors.commandPrimary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: showDots),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  NeuroColors.commandPrimary.withValues(alpha: 0.2),
                  NeuroColors.commandPrimary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
