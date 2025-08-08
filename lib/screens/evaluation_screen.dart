import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_ai_assistant/models/learning_record.dart';
import 'package:study_ai_assistant/models/study_plan.dart';
import 'package:study_ai_assistant/services/plan_service.dart';
import 'package:uuid/uuid.dart';

class EvaluationScreen extends StatefulWidget {
  final StudyPlan plan;
  final int ptCount;
  final Duration duration;

  const EvaluationScreen({
    super.key,
    required this.plan,
    required this.ptCount,
    required this.duration,
  });

  @override
  State<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen> {
  final PlanService _planService = PlanService();
  final TextEditingController _amountController = TextEditingController();
  double _concentrationLevel = 3.0; // 集中度を保持する変数

  @override
  void initState() {
    super.initState();
    // ポモドーロ完了からの遷移の場合、進捗量を自動入力
    if (widget.ptCount > 0) {
      _amountController.text = '${widget.plan.totalAmount / widget.plan.predictedPt * widget.ptCount}';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveLearningRecord() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('進捗量を正しく入力してください。')),
      );
      return;
    }

    final newRecord = LearningRecord(
      id: const Uuid().v4(), // Firestoreで自動生成される
      planId: widget.plan.id,
      date: Timestamp.now(),
      amount: amount,
      unit: widget.plan.unit,
      durationInMinutes: widget.duration.inMinutes,
      ptCount: widget.ptCount,
      concentrationLevel: _concentrationLevel.toInt(),
    );

    try {
      await _planService.addLearningRecord(newRecord);
      // 学習計画の進捗を更新
      final updatedPlan = widget.plan.copyWith(
        completedAmount: widget.plan.completedAmount + amount.toInt(),
      );
      await _planService.updatePlan(updatedPlan);

      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst); // ホーム画面に戻る
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('学習記録を保存しました！')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('記録の保存に失敗しました: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('学習の評価'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '学習お疲れ様でした！',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Text(
              widget.ptCount > 0 ? 'ポモドーロ ${widget.ptCount} 回 (${widget.duration.inMinutes} 分) が終了しました。' : '学習計画を完了します。',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
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
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _saveLearningRecord,
              child: const Text('記録して完了'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 評価せずに戻る
              },
              child: const Text('キャンセル'),
            ),
          ],
        ),
      ),
    );
  }
}
