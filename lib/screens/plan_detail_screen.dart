import 'package:flutter/material.dart';
import 'package:study_ai_assistant/models/study_plan.dart';
import 'package:study_ai_assistant/widgets/pomodoro_timer.dart';
import 'package:study_ai_assistant/services/plan_service.dart';
import 'package:study_ai_assistant/models/learning_record.dart';

import 'package:study_ai_assistant/screens/evaluation_screen.dart';
import 'package:study_ai_assistant/widgets/common/primary_button.dart';

class PlanDetailScreen extends StatefulWidget {
  const PlanDetailScreen({
    super.key,
    required this.plan,
  });

  final StudyPlan plan;

  @override
  State<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends State<PlanDetailScreen> {
  final PlanService _planService = PlanService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.plan.title),
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
                plan: widget.plan,
                autostart: true, // 自動開始
                onTimerEnd: (ptCount, duration) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EvaluationScreen(
                        plan: widget.plan,
                        ptCount: ptCount,
                        duration: duration,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32), // ボタンとの間にスペースを追加
              PrimaryButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EvaluationScreen(
                        plan: widget.plan,
                        ptCount: 0, // 完了ボタンからの遷移なので0
                        duration: Duration.zero, // 完了ボタンからの遷移なので0
                      ),
                    ),
                  );
                },
                text: '学習計画を完了する',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
