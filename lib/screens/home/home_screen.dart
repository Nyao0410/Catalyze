
import 'package:flutter/material.dart';
import 'package:study_ai_assistant/constants/app_sizes.dart';
import 'package:study_ai_assistant/services/auth_service.dart';
import 'package:study_ai_assistant/widgets/home/overall_progress_card.dart';
import 'package:study_ai_assistant/widgets/home/plan_list_preview.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface, // 修正
      appBar: AppBar(
        title: const Text('ホーム'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AuthService().logOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(p16), // AppSizes.p16 -> p16
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, '今日の進捗'),
            const OverallProgressCard(), // 作成したウィジェットを呼び出し
            const SizedBox(height: p24), // AppSizes.p24 -> p24
            _buildSectionTitle(context, '学習計画'),
            const PlanListPreview(), // 作成したウィジェットを呼び出し
          ],
        ),
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
}