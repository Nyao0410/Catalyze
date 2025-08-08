import 'package:flutter/material.dart';
import 'package:study_ai_assistant/constants/app_sizes.dart';
import 'package:study_ai_assistant/models/learning_record.dart';
import 'package:study_ai_assistant/services/plan_service.dart';
import 'package:study_ai_assistant/widgets/analysis/book_balance_pie_chart.dart';
import 'package:study_ai_assistant/widgets/analysis/weekly_bar_chart.dart';
import 'package:study_ai_assistant/widgets/error_display.dart';
import 'package:study_ai_assistant/widgets/common/loading_indicator.dart';

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
    // 2つの非同期処理を並行して実行し、両方の完了を待つ
    final results = await Future.wait([
      _planService.getWeeklyLearningRecords(),
      _planService.getBookBalanceData(),
    ]);
    return {
      'weeklyRecords': results[0] as List<LearningRecord>,
      'bookBalance': results[1] as Map<String, Duration>,
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(p16), // AppSizes.p16 -> p16
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(context, '週間学習グラフ'),
                _buildBarChartCard(context, weeklyRecords),
                const SizedBox(height: p24), // AppSizes.p24 -> p24
                _buildSectionTitle(context, '参考書バランス'),
                _buildPieChartCard(context, bookBalance),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: p4, bottom: p8), // AppSizes.p4 -> p4, AppSizes.p8 -> p8
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildBarChartCard(BuildContext context, List<LearningRecord> records) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(p12), // AppSizes.p12 -> p12
      ),
      child: Padding(
        padding: const EdgeInsets.all(p16), // AppSizes.p16 -> p16
        child: Column(
          children: [
            ToggleButtons(
              isSelected: [_barChartType == BarChartType.amount, _barChartType == BarChartType.time],
              onPressed: (index) {
                setState(() {
                  _barChartType = index == 0 ? BarChartType.amount : BarChartType.time;
                });
              },
              borderRadius: BorderRadius.circular(p8), // AppSizes.p8 -> p8
              children: const [
                Padding(padding: EdgeInsets.symmetric(horizontal: p16), child: Text('学習量')),
                Padding(padding: EdgeInsets.symmetric(horizontal: p16), child: Text('学習時間')),
              ],
            ),
            const SizedBox(height: p16), // AppSizes.p16 -> p16
            WeeklyBarChart(barChartType: _barChartType, records: records),
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
        borderRadius: BorderRadius.circular(p12), // AppSizes.p12 -> p12
      ),
      child: Padding(
        padding: const EdgeInsets.all(p16), // AppSizes.p16 -> p16
        child: BookBalancePieChart(balanceData: balanceData),
      ),
    );
  }
}
