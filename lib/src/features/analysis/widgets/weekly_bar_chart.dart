import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:catalyze/src/constants/app_sizes.dart';
import 'package:catalyze/src/features/evaluation/models/learning_record.dart';

enum BarChartType { amount, time }

class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({
    super.key,
    required this.barChartType,
    required this.records,
    required this.planTitles,
  });

  final BarChartType barChartType;
  final List<LearningRecord> records;
  final Map<String, String> planTitles;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isAmount = barChartType == BarChartType.amount;
    final weeklyData = _processRecords(isAmount);

    // 各プランIDに色を割り当てる
    final uniquePlanIds = records.map((e) => e.planId).toSet().toList();
    final List<Color> colors = [
      Colors.blue, Colors.green, Colors.red, Colors.purple, Colors.orange, Colors.teal, Colors.brown
    ];
    final Map<String, Color> planColors = {};
    for (int i = 0; i < uniquePlanIds.length; i++) {
      planColors[uniquePlanIds[i]] = colors[i % colors.length];
    }

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
                reservedSize: p24,
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: colorScheme.onSurface.withAlpha(25),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (i) {
            final dayData = weeklyData[i] ?? {};
            final List<BarChartRodStackItem> stackItems = [];
            double currentStackY = 0;

            dayData.forEach((planId, value) {
              stackItems.add(BarChartRodStackItem(
                currentStackY,
                currentStackY + value,
                planColors[planId] ?? Colors.grey,
              ));
              currentStackY += value;
            });

            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: currentStackY,
                  color: Colors.transparent,
                  width: p16,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(p4),
                    topRight: Radius.circular(p4),
                  ),
                  rodStackItems: stackItems,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // 学習記録を曜日のデータに加工する
  Map<int, Map<String, double>> _processRecords(bool isAmount) {
    final Map<int, Map<String, double>> data = {};

    for (final record in records) {
      final dayIndex = record.date.toDate().weekday - 1;
      data.putIfAbsent(dayIndex, () => {});
      
      final planId = record.planId;
      if (isAmount) {
        data[dayIndex]![planId] = (data[dayIndex]![planId] ?? 0.0) + record.amount;
      } else {
        data[dayIndex]![planId] = (data[dayIndex]![planId] ?? 0.0) + record.durationInMinutes;
      }
    }
    return data;
  }
}
