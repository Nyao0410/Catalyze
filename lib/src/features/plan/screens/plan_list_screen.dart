import 'package:catalyze/src/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:catalyze/src/constants/app_sizes.dart';
import 'package:catalyze/src/features/plan/models/study_plan.dart';
import 'package:catalyze/src/features/plan/services/plan_service.dart';
import 'package:catalyze/src/common_widgets/error_display.dart';
import 'package:catalyze/src/common_widgets/loading_indicator.dart';
import 'package:catalyze/src/features/plan/screens/plan_creation_screen.dart'; // 追加
import 'package:catalyze/src/features/plan/screens/plan_detail_screen.dart';

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
        title: const Text(AppStrings.studyPlans),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      backgroundColor: colorScheme.surface, // 修正
      body: StreamBuilder<List<StudyPlan>>(
        stream: _planService.getPlans(), // 修正
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }
          if (snapshot.hasError) {
            return ErrorDisplay(errorMessage: '${AppStrings.planListError}: ${snapshot.error}');
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(AppStrings.noStudyPlans),
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
                    '${AppStrings.planTotalAmount} ${plan.totalAmount} ${plan.unit}', // 修正
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withAlpha(178), // 0.7 * 255 = 178.5
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: colorScheme.onSurface.withAlpha(127), // 0.5 * 255 = 127.5
                    size: p16, // AppSizes.p16 -> p16
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlanDetailScreen(plan: plan),
                      ),
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PlanCreationScreen()),
          );
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