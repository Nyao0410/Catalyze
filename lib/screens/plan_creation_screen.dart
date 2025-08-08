import 'package:flutter/material.dart';
import 'package:study_ai_assistant/models/study_plan.dart';
import 'package:study_ai_assistant/services/plan_service.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class PlanCreationScreen extends StatefulWidget {
  const PlanCreationScreen({super.key});

  @override
  State<PlanCreationScreen> createState() => _PlanCreationScreenState();
}

class _PlanCreationScreenState extends State<PlanCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _planService = PlanService();

  String _title = '';
  int _totalPages = 0;
  String _unit = 'ページ';
  int _predictedPt = 0;
  DateTime _targetDate = DateTime.now().add(const Duration(days: 30));

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _targetDate) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  void _savePlan() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newPlan = StudyPlan(
        id: const Uuid().v4(),
        title: _title,
        totalPages: _totalPages,
        targetDate: _targetDate,
        creationDate: DateTime.now(),
        unit: _unit,
        description: '', // 今後の拡張用
        tags: [], // 今後の拡張用
        initialDifficulty: 3, // 今後の拡張用
        predictedPt: _predictedPt,
      );
      _planService.addStudyPlan(newPlan).then((_) {
        if (mounted) {
          Navigator.pop(context);
        }
      }).catchError((error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('エラー: 保存に失敗しました - $error')),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新しい学習計画を作成'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: '参考書名・タイトル'),
              validator: (value) => value!.isEmpty ? 'タイトルを入力してください' : null,
              onSaved: (value) => _title = value!,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: '総量（ページ数など）'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? '総量を入力してください' : null,
              onSaved: (value) => _totalPages = int.parse(value!),
            ),
            TextFormField(
              initialValue: 'ページ',
              decoration: const InputDecoration(labelText: '単位（例: ページ, 問, 章）'),
              onSaved: (value) => _unit = value!,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: '予測PT（25分=1PT）'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? '予測PTを入力してください' : null,
              onSaved: (value) => _predictedPt = int.parse(value!),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '目標日: ${DateFormat('yyyy/MM/dd').format(_targetDate)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('日付を選択'),
                ),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _savePlan,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('保存する'),
            ),
          ],
        ),
      ),
    );
  }
}
