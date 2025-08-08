import 'package:flutter/material.dart';
import 'package:study_ai_assistant/models/learning_record.dart';
import 'package:study_ai_assistant/models/study_plan.dart';
import 'package:study_ai_assistant/screens/plan_creation_screen.dart';
import 'package:study_ai_assistant/screens/plan_detail_screen.dart';
import 'package:study_ai_assistant/services/plan_service.dart';

class PlanCard extends StatelessWidget {
  final StudyPlan plan;
  final PlanService _planService = PlanService();

  PlanCard({super.key, required this.plan});

  void _onSelected(BuildContext context, String value) {
    if (value == 'edit') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlanCreationScreen(plan: plan),
        ),
      );
    } else if (value == 'delete') {
      _showDeleteConfirmDialog(context);
    }
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('計画の削除'),
          content: Text('「${plan.title}」を本当に削除しますか？この操作は元に戻せません。'),
          actions: <Widget>[
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('削除', style: TextStyle(color: Colors.redAccent)),
              onPressed: () {
                _planService.deleteStudyPlan(plan.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LearningRecord>>(
      stream: _planService.getLearningRecords(plan.id),
      builder: (context, snapshot) {
        final records = snapshot.data ?? [];
        final pagesCompleted = records.fold<int>(0, (sum, record) => sum + record.pagesCompleted);
        final progress = plan.totalPages > 0 ? pagesCompleted / plan.totalPages : 0.0;
        final remainingPages = plan.totalPages - pagesCompleted;

        final now = DateTime.now();
        final totalDuration = plan.targetDate.difference(plan.creationDate).inDays;
        final bufferDays = (totalDuration * 0.2).floor();
        final effectiveTargetDate = plan.targetDate.subtract(Duration(days: bufferDays));
        final remainingDays = effectiveTargetDate.difference(now).inDays;
        
        String dailyQuotaText;
        if (remainingPages <= 0) {
          dailyQuotaText = '完了！';
        } else if (remainingDays <= 0) {
          dailyQuotaText = '本日中に${remainingPages.toStringAsFixed(0)}${plan.unit}';
        } else {
          final dailyQuota = remainingPages / remainingDays;
          dailyQuotaText = '1日あたり約${dailyQuota.toStringAsFixed(1)}${plan.unit}';
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlanDetailScreen(plan: plan),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(plan.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) => _onSelected(context, value),
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: Text('編集'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('削除'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(dailyQuotaText, style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(204))),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('進捗率', style: TextStyle(fontSize: 14)),
                      Text('${(progress * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.withAlpha(76), // withOpacity(0.3) -> withAlpha(0.3 * 255) = 76.5
                    valueColor: AlwaysStoppedAnimation<Color>(Color.lerp(Colors.redAccent, Colors.greenAccent, progress)!),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '目標日まであと${plan.targetDate.difference(DateTime.now()).inDays}日',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(153)), // withOpacity(0.6) -> withAlpha(0.6 * 255) = 153
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
