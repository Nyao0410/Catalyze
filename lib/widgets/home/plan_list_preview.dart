import 'package:flutter/material.dart';
import 'package:study_ai_assistant/constants/app_sizes.dart';
import 'package:study_ai_assistant/models/study_plan.dart';
import 'package:study_ai_assistant/services/plan_service.dart';
import 'package:study_ai_assistant/widgets/error_display.dart';
import 'package:study_ai_assistant/widgets/common/loading_indicator.dart';
import 'package:study_ai_assistant/widgets/plan_card.dart';

class PlanListPreview extends StatelessWidget {
  const PlanListPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final planService = PlanService();

    return StreamBuilder<List<StudyPlan>>(
      stream: planService.getStudyPlans(), // plan_serviceから学習計画のStreamを取得
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }
        if (snapshot.hasError) {
          return const ErrorDisplay(errorMessage: '計画の読み込みに失敗しました。');
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('学習計画がありません。'));
        }

        final plans = snapshot.data!;

        // 既存のplan_card.dartを使ってリスト表示
        return ListView.separated(
          itemCount: plans.length,
          shrinkWrap: true, // SingleChildScrollViewの中で使うため
          physics: const NeverScrollableScrollPhysics(), // SingleChildScrollViewの中で使うため
          itemBuilder: (context, index) {
            return PlanCard(plan: plans[index]);
          },
          separatorBuilder: (context, index) => const SizedBox(height: p8), // AppSizes.p8 -> p8
        );
      },
    );
  }
}
