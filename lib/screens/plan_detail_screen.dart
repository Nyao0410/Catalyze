import 'package:flutter/material.dart';
import 'package:study_ai_assistant/models/learning_record.dart';
import 'package:study_ai_assistant/models/study_plan.dart';
import 'package:study_ai_assistant/services/plan_service.dart';
import 'package:study_ai_assistant/widgets/pomodoro_timer.dart';
import 'package:intl/intl.dart';

class PlanDetailScreen extends StatefulWidget {
  final StudyPlan plan;
  const PlanDetailScreen({super.key, required this.plan});

  @override
  State<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends State<PlanDetailScreen> {
  final PlanService _planService = PlanService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plan.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ポモドーロタイマーウィジェットを配置
            PomodoroTimer(plan: widget.plan),
            const SizedBox(height: 30),
            const Text(
              '学習履歴',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            // 学習履歴をFirestoreからリアルタイムで取得して表示
            Expanded(
              child: StreamBuilder<List<LearningRecord>>(
                stream: _planService.getLearningRecords(widget.plan.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('まだ学習履歴がありません。'));
                  }
                  final records = snapshot.data!;
                  return ListView.builder(
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      return ListTile(
                        leading: const Icon(Icons.check_circle_outline),
                        title: Text('${record.pagesCompleted} ${widget.plan.unit} (${record.actualPt} PT)'),
                        subtitle: Text(DateFormat('yyyy/MM/dd HH:mm').format(record.recordDate)),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
