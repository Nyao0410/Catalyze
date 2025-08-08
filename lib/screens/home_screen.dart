import 'package:flutter/material.dart';
import 'package:study_ai_assistant/models/study_plan.dart';
import 'package:study_ai_assistant/services/plan_service.dart';
import 'package:study_ai_assistant/widgets/plan_card.dart';
import 'package:study_ai_assistant/screens/plan_creation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PlanService _planService = PlanService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('学習計画一覧'),
        elevation: 0,
      ),
      body: StreamBuilder<List<StudyPlan>>(
        stream: _planService.getStudyPlans(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'まだ学習計画がありません。\n右下の「+」ボタンから追加しましょう！',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white54),
              ),
            );
          }

          final plans = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80), // FABと重ならないように
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              return PlanCard(plan: plan);
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
        child: const Icon(Icons.add),
      ),
    );
  }
}