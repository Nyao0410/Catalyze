import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:study_ai_assistant/constants/app_sizes.dart';

class BookBalancePieChart extends StatelessWidget {
  const BookBalancePieChart({super.key});
  // ToDo: 本来は加工済みのグラフ用データを渡すが、今回は仮のデータをウィジェット内で生成

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // 仮のデータを生成
    // ToDo: PlanServiceから取得した実績データを元にこのデータを生成する
    final pieSections = [
      PieChartSectionData(
        color: colorScheme.primary,
        value: 40,
        title: '40%',
        radius: p48, // AppSizes.p48 -> p48
        titleStyle: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: colorScheme.secondary,
        value: 30,
        title: '30%',
        radius: p48, // AppSizes.p48 -> p48
        titleStyle: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
      ),
       PieChartSectionData(
        color: colorScheme.tertiary,
        value: 15,
        title: '15%',
        radius: p48, // AppSizes.p48 -> p48
        titleStyle: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: colorScheme.onSurface.withAlpha(76),
        value: 15,
        title: '15%',
        radius: p48, // AppSizes.p48 -> p48
        titleStyle: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];


    return AspectRatio(
      aspectRatio: 1.5,
      child: PieChart(
        PieChartData(
          sectionsSpace: p4, // AppSizes.p4 -> p4
          centerSpaceRadius: p32, // AppSizes.p32 -> p32
          sections: pieSections,
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
