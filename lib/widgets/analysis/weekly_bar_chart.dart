import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:study_ai_assistant/constants/app_sizes.dart';
import 'package:study_ai_assistant/models/learning_record.dart';

enum BarChartType { amount, time }

class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({
    super.key,
    required this.barChartType,
    required this.records,
  });

  final BarChartType barChartType;
  final List<LearningRecord> records;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isAmount = barChartType == BarChartType.amount;
    final weeklyData = _processRecords(isAmount);

    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const style = TextStyle(fontSize: 10);
                  String text;
                  switch (value.toInt()) {
                    case 0: text = '月'; break;
                    case 1: text = '火'; break;
                    case 2: text = '水'; break;
                    case 3: text = '木'; break;
                    case 4: text = '金'; break;
                    case 5: text = '土'; break;
                    case 6: text = '日'; break;
                    default: text = ''; break;
                  }
                  return SideTitleWidget(axisSide: meta.axisSide, child: Text(text, style: style));
                },
                reservedSize: p24, // AppSizes.p24 -> p24
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: colorScheme.onSurface.withAlpha(25), // withOpacity(0.1) -> withAlpha(0.1 * 255) = 25.5
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: weeklyData[i],
                  color: colorScheme.primary,
                  width: p16, // AppSizes.p16 -> p16
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(p4), // AppSizes.p4 -> p4
                    topRight: Radius.circular(p4), // AppSizes.p4 -> p4
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // 学習記録を曜日のデータに加工する
  List<double> _processRecords(bool isAmount) {
    List<double> data = List.filled(7, 0.0); // 月曜〜日曜

    for (final record in records) {
      final dayIndex = record.date.toDate().weekday - 1; // 月曜=0, ...
      if (isAmount) {
        data[dayIndex] += record.amount;
      } else {
        data[dayIndex] += record.durationInMinutes;
      }
    }
    return data;
  }
}
