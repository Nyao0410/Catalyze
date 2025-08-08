import 'package:flutter/material.dart';
import 'package:study_ai_assistant/models/study_plan.dart';
import 'package:study_ai_assistant/widgets/pomodoro_timer.dart';
import 'package:study_ai_assistant/services/plan_service.dart';
import 'package:study_ai_assistant/models/learning_record.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 追加

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
  final TextEditingController _amountController = TextEditingController();
  double _concentrationLevel = 3.0; // 集中度を保持する変数

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _showLearningRecordDialog(int ptCount, Duration duration) async {
    _amountController.text = ''; // ダイアログ表示前にリセット
    _concentrationLevel = 3.0; // ダイアログ表示前にリセット

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // ユーザーがダイアログの外をタップしても閉じない
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('学習記録の入力'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('ポモドーロ ${ptCount} 回が終了しました。'),
                    Text('学習時間: ${duration.inMinutes} 分'),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '進捗量 (${widget.plan.unit})',
                        hintText: '例: 10',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('集中度: ${_concentrationLevel.toInt()}'),
                    Slider(
                      value: _concentrationLevel,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: _concentrationLevel.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          _concentrationLevel = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('キャンセル'),
                  onPressed: () {
                    if (!mounted) return;
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('記録する'),
                  onPressed: () async {
                    final amount = double.tryParse(_amountController.text) ?? 0.0;
                    if (amount <= 0) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('進捗量を正しく入力してください。')),
                      );
                      return;
                    }

                    final newRecord = LearningRecord(
                      id: '', // Firestoreで自動生成される
                      planId: widget.plan.id,
                      date: Timestamp.now(),
                      amount: amount,
                      unit: widget.plan.unit,
                      durationInMinutes: duration.inMinutes,
                      ptCount: ptCount,
                      concentrationLevel: _concentrationLevel.toInt(),
                    );

                    try {
                      await _planService.addLearningRecord(newRecord);
                      // 学習計画の進捗を更新
                      final updatedPlan = widget.plan.copyWith(
                        completedAmount: widget.plan.completedAmount + amount.toInt(), // amountがdoubleなのでtoInt()を追加
                      );
                      await _planService.updatePlan(updatedPlan);

                      if (!mounted) return;
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('学習記録を保存しました！')),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('記録の保存に失敗しました: $e')),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

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
                onTimerEnd: (ptCount, duration) {
                  _showLearningRecordDialog(ptCount, duration);
                },
              ),
              const SizedBox(height: 32),
              // 学習履歴の表示
              StreamBuilder<List<LearningRecord>>(
                stream: _planService.getLearningRecords(widget.plan.id),
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
                        title: Text('${record.amount} ${widget.plan.unit} (${record.ptCount} PT)'),
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
