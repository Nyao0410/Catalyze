
import 'package:flutter/material.dart';
import 'package:study_ai_assistant/constants/app_sizes.dart';
import 'package:study_ai_assistant/services/auth_service.dart';
import 'package:study_ai_assistant/widgets/home/overall_progress_card.dart';

import 'package:study_ai_assistant/widgets/plan_card.dart';
import 'package:study_ai_assistant/services/plan_service.dart'; // 追加
import 'package:study_ai_assistant/models/study_plan.dart'; // 追加
import 'package:study_ai_assistant/screens/plan_creation_screen.dart'; // 追加

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PlanService _planService = PlanService();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
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
        padding: const EdgeInsets.all(p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, '今日の進捗'),
            const OverallProgressCard(),
            const SizedBox(height: p24),
            _buildSectionTitle(context, '学習計画'),
            StreamBuilder<List<StudyPlan>>(
              stream: _planService.getPlans(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('エラー: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('まだ学習計画がありません。'));
                }
                final plans = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: plans.length,
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    return PlanCard(plan: plan);
                  },
                );
              },
            ),
          ],
        ),
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

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: p4, bottom: p8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}