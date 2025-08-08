import 'package:flutter/material.dart';
import 'package:study_ai_assistant/models/learning_record.dart';
import 'package:study_ai_assistant/models/study_plan.dart';
import 'package:study_ai_assistant/services/plan_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final PlanService _planService = PlanService();
  late Future<Map<String, dynamic>> _analysisDataFuture;

  @override
  void initState() {
    super.initState();
    _analysisDataFuture = _fetchAnalysisData();
  }

  Future<Map<String, dynamic>> _fetchAnalysisData() async {
    final plans = await _planService.getStudyPlans().first;
    final Map<String, List<LearningRecord>> allRecords = {};
    for (final plan in plans) {
      final records = await _planService.getLearningRecords(plan.id).first;
      allRecords[plan.id] = records;
    }
    return {'plans': plans, 'allRecords': allRecords};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('学習分析'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _analysisDataFuture = _fetchAnalysisData();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _analysisDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
          }
          if (!snapshot.hasData || (snapshot.data!['plans'] as List).isEmpty) {
            return const Center(child: Text('分析対象のデータがありません。'));
          }

          final List<StudyPlan> plans = snapshot.data!['plans'];
          final Map<String, List<LearningRecord>> allRecords = snapshot.data!['allRecords'];

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildWeeklyChart(allRecords),
              const SizedBox(height: 24),
              _buildBalanceChart(plans, allRecords),
              const SizedBox(height: 24),
              _buildGapAnalysis(plans, allRecords),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildWeeklyChart(Map<String, List<LearningRecord>> allRecords) {
    final weeklyData = <int, double>{ for (int i = 0; i < 7; i++) i: 0.0 };
    final today = DateTime.now();

    allRecords.values.expand((records) => records).forEach((record) {
      final diff = today.difference(record.recordDate).inDays;
      if (diff >= 0 && diff < 7) {
        weeklyData[diff] = (weeklyData[diff] ?? 0.0) + record.actualPt;
      }
    });

    final barGroups = List.generate(7, (index) {
      final dayIndex = 6 - index;
      return BarChartGroupData(
        x: index,
        barRods: [BarChartRodData(toY: weeklyData[dayIndex] ?? 0.0, color: Colors.lightBlueAccent, width: 16)],
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('週間学習時間 (PT)'),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              barGroups: barGroups,
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final day = today.subtract(Duration(days: 6 - value.toInt()));
                      return Text(DateFormat('E', 'ja_JP').format(day));
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: true, drawVerticalLine: false),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceChart(List<StudyPlan> plans, Map<String, List<LearningRecord>> allRecords) {
    final Map<String, double> balanceData = {};
    for (final plan in plans) {
      final totalPt = allRecords[plan.id]!.fold<double>(0.0, (sum, record) => sum + record.actualPt);
      if (totalPt > 0) {
        balanceData[plan.title] = totalPt;
      }
    }
    if (balanceData.isEmpty) return const SizedBox.shrink();

    final pieChartSections = balanceData.entries.map((entry) {
      return PieChartSectionData(
        value: entry.value,
        title: '${entry.value.toStringAsFixed(0)} PT',
        color: Colors.primaries[balanceData.keys.toList().indexOf(entry.key) % Colors.primaries.length],
        radius: 80,
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('参考書バランス'),
        SizedBox(height: 200, child: PieChart(PieChartData(sections: pieChartSections))),
      ],
    );
  }
  
  Widget _buildGapAnalysis(List<StudyPlan> plans, Map<String, List<LearningRecord>> allRecords) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('予測PTギャップ分析'),
        ...plans.map((plan) {
          final totalActualPt = allRecords[plan.id]!.fold<int>(0, (sum, record) => sum + record.actualPt);
          final gap = totalActualPt - plan.predictedPt;
          final gapText = gap > 0 ? '+$gap PT' : '$gap PT';
          final color = gap > 0 ? Colors.orangeAccent : Colors.lightGreenAccent;

          return Card(
            child: ListTile(
              title: Text(plan.title),
              subtitle: Text('予測: ${plan.predictedPt} PT / 実績: $totalActualPt PT'),
              trailing: Text(gapText, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          );
        }),
      ],
    );
  }
}