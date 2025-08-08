import 'package:flutter/material.dart';
import 'package:catalyze/constants/app_sizes.dart';
import 'package:catalyze/models/study_plan.dart';
import 'package:catalyze/services/plan_service.dart';
import 'package:catalyze/widgets/error_display.dart';
import 'package:catalyze/widgets/common/loading_indicator.dart';
import 'package:catalyze/widgets/plan_card.dart';

class PlanListPreview extends StatelessWidget {
  const PlanListPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final planService = PlanService();

    return StreamBuilder<List<StudyPlan>>(
      stream: planService.getPlans(), // 修正
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
