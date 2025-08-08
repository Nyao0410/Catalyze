import 'package:flutter/material.dart';
import 'package:study_ai_assistant/constants/app_sizes.dart';
import 'package:study_ai_assistant/models/study_plan.dart'; // 修正
import 'package:study_ai_assistant/services/plan_service.dart';
import 'package:study_ai_assistant/widgets/error_display.dart';
import 'package:study_ai_assistant/widgets/common/loading_indicator.dart';
// 修正点1: 詳細画面のインポート（仮のパス。実際のパスに合わせて修正が必要）
// import 'package:study_ai_assistant/screens/plan/plan_detail_screen.dart';

class PlanListScreen extends StatefulWidget {
  const PlanListScreen({super.key});

  @override
  State<PlanListScreen> createState() => _PlanListScreenState();
}

class _PlanListScreenState extends State<PlanListScreen> {
  final _planService = PlanService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('学習計画'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      backgroundColor: colorScheme.surface, // 修正
      body: StreamBuilder<List<StudyPlan>>(
        stream: _planService.getStudyPlans(), // 修正
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }
          if (snapshot.hasError) {
            return ErrorDisplay(errorMessage: '計画の読み込みに失敗しました: ${snapshot.error}');
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('まだ学習計画がありません。'),
            );
          }

          final plans = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(p8), // AppSizes.p8 -> p8
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: p8, // AppSizes.p8 -> p8
                  vertical: p4, // AppSizes.p4 -> p4
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(p12), // AppSizes.p12 -> p12
                ),
                elevation: 1,
                color: colorScheme.surface,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: p24, // AppSizes.p20 -> p24 (p20がないため)
                    vertical: p12, // AppSizes.p12 -> p12
                  ),
                  title: Text(
                    plan.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    '総量 ${plan.totalPages} ${plan.unit}', // 修正
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withAlpha(178), // withOpacity(0.7) -> withAlpha(0.7 * 255) = 178.5
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: colorScheme.onSurface.withAlpha(127), // withOpacity(0.5) -> withAlpha(0.5 * 255) = 127.5
                    size: p16, // AppSizes.p16 -> p16
                  ),
                  // 修正点2: onTapイベントを復活させ、詳細画面への遷移ロジックを追加
                  onTap: () {
                    // ToDo: PlanDetailScreenがまだないので、コメントアウトしています。
                    //       詳細画面のファイルが作成されたら、このコメントを解除してください。
                    /*
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlanDetailScreen(plan: plan),
                      ),
                    );
                    */
                    // 機能が復活したことを確認するため、一時的にSnackBarを表示します
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${plan.title} がタップされました')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 計画作成画面への遷移を実装
        },
        backgroundColor: colorScheme.primary,
        child: Icon(
          Icons.add,
          color: colorScheme.onPrimary,
        ),
      ),
    );
  }
}