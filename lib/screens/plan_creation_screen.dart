import 'package:flutter/material.dart';
import 'package:study_ai_assistant/constants/app_sizes.dart';
import 'package:study_ai_assistant/models/study_plan.dart';
import 'package:study_ai_assistant/services/plan_service.dart';
import 'package:study_ai_assistant/widgets/common/primary_button.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Timestampのために追加

class PlanCreationScreen extends StatefulWidget {
  // 編集用に既存の計画を受け取れるようにする
  final StudyPlan? plan;
  const PlanCreationScreen({super.key, this.plan});

  @override
  State<PlanCreationScreen> createState() => _PlanCreationScreenState();
}

class _PlanCreationScreenState extends State<PlanCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _planService = PlanService();
  late bool _isEditing;

  // --- Form State ---
  late String _title;
  late int _totalAmount;
  late String _unit;
  late int _predictedPt;
  late DateTime _deadline;
  late String _description;
  late int _priority;
  late bool _isActive;
  // ------------------

  @override
  void initState() {
    super.initState();
    _isEditing = widget.plan != null;
    // 編集モードの場合は、既存のデータで初期化
    _title = widget.plan?.title ?? '';
    _totalAmount = widget.plan?.totalAmount ?? 0;
    _unit = widget.plan?.unit ?? 'ページ';
    _predictedPt = widget.plan?.predictedPt ?? 0;
    _deadline = widget.plan?.deadline?.toDate() ?? DateTime.now().add(const Duration(days: 30));
    _description = widget.plan?.description ?? '';
    _priority = widget.plan?.priority ?? 2;
    _isActive = widget.plan?.isActive ?? true;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _deadline) {
      setState(() {
        _deadline = picked;
      });
    }
  }

  void _savePlan() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final planData = StudyPlan(
        id: widget.plan?.id ?? const Uuid().v4(),
        title: _title,
        totalAmount: _totalAmount,
        createdAt: widget.plan?.createdAt ?? Timestamp.now(),
        unit: _unit,
        deadline: Timestamp.fromDate(_deadline),
        priority: _priority,
        isActive: _isActive,
        completedAmount: widget.plan?.completedAmount ?? 0, // 編集時は既存の値を保持
      );

      final future = _isEditing
          ? _planService.updatePlan(planData)
          : _planService.addPlan(planData);

      future.then((_) {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? '計画を編集' : '新しい学習計画を作成')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(p16),
          children: [
            TextFormField(
              initialValue: _title,
              decoration: const InputDecoration(labelText: '参考書名・タイトル'),
              validator: (value) => value!.isEmpty ? '入力してください' : null,
              onSaved: (value) => _title = value!,
            ),
            gapH16,
            TextFormField(
              initialValue: _description,
              decoration: const InputDecoration(labelText: '説明（任意）'),
              onSaved: (value) => _description = value ?? '',
            ),
            gapH16,
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _totalAmount.toString(),
                    decoration: const InputDecoration(labelText: '総量'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? '入力' : null,
                    onSaved: (value) => _totalAmount = int.parse(value!),
                  ),
                ),
                gapW16,
                Expanded(
                  child: TextFormField(
                    initialValue: _unit,
                    decoration: const InputDecoration(labelText: '単位'),
                    onSaved: (value) => _unit = value!,
                  ),
                ),
              ],
            ),
            gapH16,
            TextFormField(
              initialValue: _predictedPt.toString(),
              decoration: const InputDecoration(labelText: '予測PT（25分=1PT）'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? '入力' : null,
              onSaved: (value) => _predictedPt = int.parse(value!), 
            ),
            gapH24,
            const Text('初期難易度', style: TextStyle(fontSize: 16)),
            _StarRating(
              rating: _priority, // priorityを難易度として使用
              onRatingChanged: (rating) => setState(() => _priority = rating),
            ),
            gapH24,
            Row(
              children: [
                Expanded(
                  child: Text(
                    '目標日: ${DateFormat('yyyy/MM/dd').format(_deadline)}',
                  ),
                ),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('日付を選択'),
                ),
              ],
            ),
            gapH32,
            PrimaryButton(onPressed: _savePlan, text: _isEditing ? '更新する' : '保存する'),
          ],
        ),
      ),
    );
  }
}

// 星評価のためのカスタムウィジェット
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
