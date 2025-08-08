import 'package:flutter/material.dart';
import 'package:study_ai_assistant/constants/app_sizes.dart';
import 'package:study_ai_assistant/widgets/analysis/book_balance_pie_chart.dart';
import 'package:study_ai_assistant/widgets/analysis/weekly_bar_chart.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  // 棒グラフの表示種別を管理する状態変数
  BarChartType _barChartType = BarChartType.amount;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(p16), // AppSizes.p16 -> p16
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, '週間学習グラフ'),
            _buildBarChartCard(context),
            const SizedBox(height: p24), // AppSizes.p24 -> p24
            _buildSectionTitle(context, '参考書バランス'),
            _buildPieChartCard(context),
          ],
        ),
      ),
    );
  }

  // セクションタイトルを生成するヘルパーメソッド
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

  // 棒グラフのカードUI
  Widget _buildBarChartCard(BuildContext context) {
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
            // 「学習量」「学習時間」を切り替えるトグル
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
            // 新しく作成した棒グラフウィジェットを呼び出し
            WeeklyBarChart(barChartType: _barChartType),
          ],
        ),
      ),
    );
  }

  // 円グラフのカードUI
  Widget _buildPieChartCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(p12), // AppSizes.p12 -> p12
      ),
      child: const Padding(
        padding: EdgeInsets.all(p16), // AppSizes.p16 -> p16
        // 新しく作成した円グラフウィジェットを呼び出し
        child: BookBalancePieChart(),
      ),
    );
  }
}
