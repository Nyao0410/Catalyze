import 'package:flutter/material.dart';
import 'package:study_ai_assistant/constants/app_sizes.dart';
import 'package:study_ai_assistant/models/learning_record.dart';
import 'package:study_ai_assistant/services/plan_service.dart';
import 'package:study_ai_assistant/widgets/analysis/book_balance_pie_chart.dart';
import 'package:study_ai_assistant/widgets/analysis/weekly_bar_chart.dart';
import 'package:study_ai_assistant/widgets/error_display.dart';
import 'package:study_ai_assistant/widgets/common/loading_indicator.dart';
import 'package:study_ai_assistant/models/study_plan.dart';
import 'package:intl/intl.dart'; // 追加

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final _planService = PlanService();
  BarChartType _barChartType = BarChartType.amount;

  // FutureBuilderで複数のFutureを扱うためのFuture
  late Future<Map<String, dynamic>> _analysisDataFuture;

  @override
  void initState() {
    super.initState();
    _analysisDataFuture = _loadAnalysisData();
  }
  
  Future<Map<String, dynamic>> _loadAnalysisData() async {
    // 複数の非同期処理を並行して実行し、両方の完了を待つ
    final results = await Future.wait([
      _planService.getWeeklyLearningRecords(),
      _planService.getBookBalanceData(),
      _planService.getPlans().first, // StreamなのでfirstでFutureに変換
      _planService.getAllLearningRecords(), // 追加
    ]);

    final List<StudyPlan> plans = results[2] as List<StudyPlan>;
    final Map<String, String> planTitles = {
      for (var plan in plans) plan.id: plan.title
    };

    return {
      'weeklyRecords': results[0] as List<LearningRecord>,
      'bookBalance': results[1] as Map<String, Duration>,
      'planTitles': planTitles,
      'allLearningRecords': results[3] as List<LearningRecord>, // 追加
    };
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('分析'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _analysisDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }
          if (snapshot.hasError) {
            return ErrorDisplay(errorMessage: '分析データの読み込みに失敗しました: ${snapshot.error}');
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('データがありません。'));
          }
          
          final weeklyRecords = snapshot.data!['weeklyRecords'] as List<LearningRecord>;
          final bookBalance = snapshot.data!['bookBalance'] as Map<String, Duration>;
          final planTitles = snapshot.data!['planTitles'] as Map<String, String>;
          final allLearningRecords = snapshot.data!['allLearningRecords'] as List<LearningRecord>; // 追加

          return SingleChildScrollView(
            padding: const EdgeInsets.all(p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(context, '週間学習グラフ'),
                _buildBarChartCard(context, weeklyRecords, planTitles),
                const SizedBox(height: p24),
                _buildSectionTitle(context, '参考書バランス'),
                _buildPieChartCard(context, bookBalance),
                const SizedBox(height: p24), // 追加
                _buildSectionTitle(context, '過去の学習記録'), // 追加
                _buildLearningRecordsListCard(context, allLearningRecords, planTitles), // 追加
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: p4, bottom: p8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildBarChartCard(BuildContext context, List<LearningRecord> records, Map<String, String> planTitles) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(p12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(p16),
        child: Column(
          children: [
            ToggleButtons(
              isSelected: [_barChartType == BarChartType.amount, _barChartType == BarChartType.time],
              onPressed: (index) {
                setState(() {
                  _barChartType = index == 0 ? BarChartType.amount : BarChartType.time;
                });
              },
              borderRadius: BorderRadius.circular(p8),
              children: const [
                Padding(padding: EdgeInsets.symmetric(horizontal: p16), child: Text('学習量')),
                Padding(padding: EdgeInsets.symmetric(horizontal: p16), child: Text('学習時間')),
              ],
            ),
            const SizedBox(height: p16),
            WeeklyBarChart(barChartType: _barChartType, records: records, planTitles: planTitles),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartCard(BuildContext context, Map<String, Duration> balanceData) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(p12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(p16),
        child: BookBalancePieChart(balanceData: balanceData),
      ),
    );
  }

  Widget _buildLearningRecordsListCard(BuildContext context, List<LearningRecord> records, Map<String, String> planTitles) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(p12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (records.isEmpty)
              const Text('まだ学習記録がありません。')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final record = records[index];
                  final planTitle = planTitles[record.planId] ?? '不明な計画';
                  return ListTile(
                    title: Text('${record.amount} ${record.unit} (${record.ptCount} PT) - $planTitle'),
                    subtitle: Text(
                      '${DateFormat('yyyy/MM/dd HH:mm').format(record.date.toDate())} | 集中度: ${record.concentrationLevel} | 難易度: ${record.difficulty}',
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
