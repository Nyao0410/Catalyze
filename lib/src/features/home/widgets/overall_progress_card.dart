import 'package:catalyze/src/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:catalyze/src/constants/app_sizes.dart';
import 'package:catalyze/src/features/plan/services/plan_service.dart';
import 'package:catalyze/src/common_widgets/loading_indicator.dart';

class OverallProgressCard extends StatelessWidget {
  const OverallProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final planService = PlanService();

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(p12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(p16),
        child: FutureBuilder<Map<String, double>>(
          future: planService.getOverallProgress(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 50, child: LoadingIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const Text(AppStrings.overallProgressError);
            }

            final totalDailyQuotaAmount = snapshot.data!['totalDailyQuotaAmount']!;
            final totalCompletedAmountToday = snapshot.data!['totalCompletedAmountToday']!;
            final progress = totalDailyQuotaAmount > 0 ? totalCompletedAmountToday / totalDailyQuotaAmount : 0.0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.overallProgressTitle, style: textTheme.titleMedium),
                const SizedBox(height: p8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(p8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: p12,
                          backgroundColor: colorScheme.primary.withAlpha(51),
                          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: p16),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: p8),
                Text(
                  '${totalCompletedAmountToday.toStringAsFixed(1)} / ${totalDailyQuotaAmount.toStringAsFixed(1)} (今日の目標)',
                  style: textTheme.bodySmall,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
