import 'package:flutter/material.dart';
import 'package:study_ai_assistant/constants/app_sizes.dart';
import 'package:study_ai_assistant/services/plan_service.dart';
import 'package:study_ai_assistant/widgets/common/loading_indicator.dart';

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
        borderRadius: BorderRadius.circular(p12), // AppSizes.p12 -> p12
      ),
      child: Padding(
        padding: const EdgeInsets.all(p16), // AppSizes.p16 -> p16
        child: FutureBuilder<double>(
          future: planService.getOverallProgress(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 50, child: LoadingIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const Text('進捗データの読み込みに失敗しました。');
            }

            final progress = snapshot.data!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('全体の達成度', style: textTheme.titleMedium),
                const SizedBox(height: p8), // AppSizes.p8 -> p8
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(p8), // AppSizes.p8 -> p8
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: p12, // AppSizes.p12 -> p12
                          backgroundColor: colorScheme.primary.withAlpha(51), // withOpacity(0.2) -> withAlpha(0.2 * 255) = 51
                          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: p16), // AppSizes.p16 -> p16
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
