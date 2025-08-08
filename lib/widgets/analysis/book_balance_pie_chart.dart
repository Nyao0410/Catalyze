import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:study_ai_assistant/constants/app_sizes.dart';

class BookBalancePieChart extends StatelessWidget {
  const BookBalancePieChart({
    super.key,
    required this.balanceData,
  });

  final Map<String, Duration> balanceData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final colors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      colorScheme.primary.withAlpha(127),
      colorScheme.secondary.withAlpha(127),
    ];
    
    final totalDuration = balanceData.values.fold(Duration.zero, (prev, e) => prev + e);
    int colorIndex = 0;

    return AspectRatio(
      aspectRatio: 1.5,
      child: PieChart(
        PieChartData(
          sectionsSpace: p4, // AppSizes.p4 -> p4
          centerSpaceRadius: p32, // AppSizes.p32 -> p32
          sections: balanceData.entries.map((entry) {
            final percentage = totalDuration.inMinutes == 0 ? 0 : (entry.value.inMinutes / totalDuration.inMinutes) * 100;
            final color = colors[colorIndex++ % colors.length];
            return PieChartSectionData(
              color: color,
              value: entry.value.inMinutes.toDouble(),
              title: '${percentage.toStringAsFixed(0)}%',
              radius: p48, // AppSizes.p48 -> p48
              titleStyle: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
            );
          }).toList(),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
