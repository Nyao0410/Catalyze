import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:study_ai_assistant/models/study_plan.dart';
import 'package:study_ai_assistant/screens/add_plan_screen.dart';
import 'package:study_ai_assistant/screens/learning_screen.dart';
import 'package:study_ai_assistant/services/plan_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _showDeleteConfirmation(BuildContext context, StudyPlan plan) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('計画の削除'),
          content: Text('「${plan.title}」を本当に削除しますか？この操作は元に戻せません。'),
          actions: <Widget>[
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            TextButton(
              child: const Text('削除', style: TextStyle(color: Colors.red)),
              onPressed: () {
                PlanService.deletePlan(plan);
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Color _getProgressColor(double progress) {
    return Color.lerp(Colors.redAccent, Colors.lightBlueAccent, progress)!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ホーム')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddPlanScreen())),
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: ValueListenableBuilder(
        valueListenable: PlanService.getPlansBox().listenable(),
        builder: (context, Box<StudyPlan> box, _) {
          final plans = box.values.toList();
          if (plans.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('下の「＋」ボタンから学習計画を追加しよう！', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.grey)),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              final progress = plan.totalPages > 0 ? plan.completedPages / plan.totalPages : 0.0;
              final isAchieved = plan.dailyTarget > 0 && plan.pagesCompletedToday >= plan.dailyTarget;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                  title: Text(plan.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      isAchieved
                          ? const Text('今日のノルマ: 達成', style: TextStyle(color: Colors.amber))
                          : Text('今日のノルマ: ${plan.dailyTarget} ${plan.unit}'),
                      const SizedBox(height: 4),
                      Text('進捗: ${plan.completedPages} / ${plan.totalPages} ${plan.unit}'),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[800],
                        valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(progress)),
                        minHeight: 6,
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddPlanScreen(planToEdit: plan)));
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(context, plan);
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(value: 'edit', child: Text('編集')),
                      const PopupMenuItem<String>(value: 'delete', child: Text('削除')),
                    ],
                  ),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => LearningScreen(plan: plan))),
                ),
              );
            },
          );
        },
      ),
    );
  }
}