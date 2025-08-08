import 'package:flutter/material.dart';
import 'package:study_ai_assistant/models/study_plan.dart';
import 'package:study_ai_assistant/widgets/pomodoro_timer.dart';
import 'package:study_ai_assistant/services/plan_service.dart'; // 追加
import 'package:study_ai_assistant/models/learning_record.dart'; // 追加
import 'package:intl/intl.dart'; // 追加

class PlanDetailScreen extends StatelessWidget {
  const PlanDetailScreen({
    super.key,
    required this.plan,
  });

  final StudyPlan plan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final planService = PlanService(); // 追加

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(plan.title),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PomodoroTimer(
                plan: plan, // planを渡す
                // autostart: true, // autostartはPomodoroTimer内部で管理
                // onTimerEnd: () { // onTimerEndはPomodoroTimer内部で管理
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     const SnackBar(content: Text('1PT終了！記録画面を表示します。')),
                //   );
                // },
              ),
              const SizedBox(height: 32),
              // 学習履歴の表示
              StreamBuilder<List<LearningRecord>>(
                stream: planService.getLearningRecords(plan.id), // 修正
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('エラー: ${snapshot.error}');
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('まだ学習記録がありません。');
                  }
                  final records = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      return ListTile(
                        title: Text('${record.amount} ${plan.unit} (${record.ptCount} PT)'),
                        subtitle: Text(DateFormat('yyyy/MM/dd HH:mm').format(record.date.toDate())),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
