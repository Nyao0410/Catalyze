import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:study_ai_assistant/models/study_plan.dart';
import 'package:study_ai_assistant/services/plan_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});
  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  bool _showTimeData = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('分析')),
      body: ValueListenableBuilder(
        valueListenable: PlanService.getPlansBox().listenable(),
        builder: (context, Box<StudyPlan> box, _) {
          final plans = box.values.toList();
          if (plans.isEmpty || plans.every((p) => p.records.isEmpty)) {
            return const Center(child: Text('学習記録がありません', style: TextStyle(fontSize: 18, color: Colors.grey)));
          }
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildBarChartCard(plans),
              const SizedBox(height: 16),
              _buildPieChartCard(plans),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBarChartCard(List<StudyPlan> plans) {
    final weeklyData = _getWeeklyData(plans, _showTimeData);
    final maxY = (weeklyData.values.isEmpty ? 10.0 : weeklyData.values.reduce(max) * 1.2).ceilToDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.center,
              child: ToggleButtons(
                isSelected: [_showTimeData, !_showTimeData],
                onPressed: (index) => setState(() => _showTimeData = index == 0),
                borderRadius: BorderRadius.circular(8),
                children: const [
                  Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('学習時間')),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('学習量')),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  barGroups: _generateBarGroups(weeklyData),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: _getBottomTitles, reservedSize: 22)),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<int, double> _getWeeklyData(List<StudyPlan> plans, bool isTime) {
    final Map<int, double> data = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    for (var plan in plans) {
      for (var record in plan.records) {
        if (!record.recordDate.isBefore(startOfWeek)) {
          final day = record.recordDate.weekday;
          if (isTime) {
            data[day] = (data[day] ?? 0) + (record.durationInSeconds / 60); // minutes
          } else {
            data[day] = (data[day] ?? 0) + record.pagesCompleted;
          }
        }
      }
    }
    return data;
  }

  List<BarChartGroupData> _generateBarGroups(Map<int, double> weeklyData) {
    return List.generate(7, (index) {
      final day = index + 1;
      return BarChartGroupData(
        x: day,
        barRods: [BarChartRodData(toY: weeklyData[day] ?? 0, color: Colors.lightBlueAccent, width: 16, borderRadius: BorderRadius.circular(4))],
      );
    });
  }

  Widget _getBottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10);
    String text;
    switch (value.toInt()) {
      case 1: text = '月'; break;
      case 2: text = '火'; break;
      case 3: text = '水'; break;
      case 4: text = '木'; break;
      case 5: text = '金'; break;
      case 6: text = '土'; break;
      case 7: text = '日'; break;
      default: text = ''; break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide, // This line is the fix.
      child: Text(text, style: style),
    );
  }

  Widget _buildPieChartCard(List<StudyPlan> plans) {
    final pieData = _getPieData(plans);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('参考書別 学習時間', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: pieData.isEmpty 
                  ? const Center(child: Text('データがありません'))
                  : PieChart(
                      PieChartData(
                        sections: pieData,
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getPieData(List<StudyPlan> plans) {
    final totalDuration = plans.fold<double>(0, (sum, p) => sum + p.records.fold(0, (s, r) => s + r.durationInSeconds));
    if (totalDuration == 0) return [];
    
    final List<Color> colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red, Colors.teal, Colors.pink];
    int colorIndex = 0;

    return plans.where((p) => p.records.isNotEmpty).map((plan) {
      final planDuration = plan.records.fold<double>(0, (s, r) => s + r.durationInSeconds);
      final percentage = (planDuration / totalDuration) * 100;
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      return PieChartSectionData(
        color: color,
        value: planDuration,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(blurRadius: 2)]),
        badgeWidget: Text(plan.title, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
        badgePositionPercentageOffset: 1.2,
      );
    }).toList();
  }
}