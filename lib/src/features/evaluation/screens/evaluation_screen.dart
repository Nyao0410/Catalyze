import 'package:catalyze/src/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:catalyze/src/features/evaluation/models/learning_record.dart';
import 'package:catalyze/src/features/plan/models/study_plan.dart';
import 'package:catalyze/src/features/plan/services/plan_service.dart';
import 'package:uuid/uuid.dart';
import 'package:catalyze/src/common_widgets/primary_button.dart'; // 追加
import 'package:catalyze/src/common_widgets/secondary_button.dart';

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
  int _concentrationLevel = 3; // 集中度を保持する変数 (intに変更)
  int _difficultyLevel = 3; // 難易度を保持する変数 (intに変更)

  @override
  void initState() {
    super.initState();
    // ポモドーロ完了からの遷移の場合、進捗量を自動入力
    if (widget.ptCount > 0) {
      // 予測PTが0でない場合のみ計算
      if (widget.plan.predictedPt > 0) {
        _amountController.text = (widget.plan.totalAmount / widget.plan.predictedPt * widget.ptCount).toStringAsFixed(1);
      } else {
        _amountController.text = '0.0'; // 予測PTが0の場合は0を設定
      }
    } else {
      // 完了ボタンからの遷移の場合、現在の完了量から開始
      _amountController.text = widget.plan.completedAmount.toString();
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
        const SnackBar(content: Text(AppStrings.evaluationInputError)),
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
      concentrationLevel: _concentrationLevel, // intのまま
      difficulty: _difficultyLevel, // intのまま
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
        const SnackBar(content: Text(AppStrings.evaluationSaveSuccess)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.evaluationSaveFailure(e.toString()))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.evaluationTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.evaluationMessage,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Text(
              widget.ptCount > 0 ? AppStrings.evaluationPomodoroMessage(widget.ptCount, widget.duration.inMinutes) : AppStrings.evaluationCompleteMessage,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // 進捗量
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: double.tryParse(_amountController.text) ?? widget.plan.completedAmount.toDouble(),
                    min: widget.plan.completedAmount.toDouble(),
                    max: widget.plan.totalAmount.toDouble(),
                    divisions: (widget.plan.totalAmount - widget.plan.completedAmount).toInt() > 0 ? (widget.plan.totalAmount - widget.plan.completedAmount).toInt() : 1,
                    label: (double.tryParse(_amountController.text) ?? widget.plan.completedAmount.toDouble()).toStringAsFixed(1),
                    onChanged: (double value) {
                      setState(() {
                        _amountController.text = value.toStringAsFixed(1);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: AppStrings.evaluationProgressAmountWithUnit(widget.plan.unit),
                      hintText: AppStrings.evaluationExampleHint,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 集中度
            const Text(AppStrings.evaluationConcentration),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) {
                final isSelected = _concentrationLevel == index + 1;
                final emojis = ['☹️', '😐', '😁'];
                return GestureDetector(
                  onTap: () => setState(() => _concentrationLevel = index + 1),
                  child: Opacity(
                    opacity: isSelected ? 1.0 : 0.5,
                    child: Text(emojis[index], style: const TextStyle(fontSize: 32)),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            // 難易度
            const Text(AppStrings.evaluationDifficulty),
            _StarRating(
              rating: _difficultyLevel,
              onRatingChanged: (rating) => setState(() => _difficultyLevel = rating),
            ),
            const SizedBox(height: 40),
            PrimaryButton(
              onPressed: _saveLearningRecord,
              text: AppStrings.evaluationSaveAndComplete,
            ),
            const SizedBox(height: 16), // ボタン間のスペース
            SecondaryButton(
              onPressed: () {
                Navigator.of(context).pop(); // 評価せずに戻る
              },
              text: AppStrings.cancel,
            ),
          ],
        ),
      ),
    );
  }
}

// 星評価のためのカスタムウィジェット (PlanCreationScreenからコピー)
class _StarRating extends StatelessWidget {
  final int rating;
  final Function(int) onRatingChanged;

  const _StarRating({required this.rating, required this.onRatingChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: () => onRatingChanged(index + 1),
          icon: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
          ),
        );
      }),
    );
  }
}
