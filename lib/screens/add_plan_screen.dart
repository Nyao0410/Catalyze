import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:study_ai_assistant/models/study_plan.dart';
import 'package:study_ai_assistant/services/plan_service.dart';
import 'package:uuid/uuid.dart';

class AddPlanScreen extends StatefulWidget {
  final StudyPlan? planToEdit;

  const AddPlanScreen({super.key, this.planToEdit});

  @override
  State<AddPlanScreen> createState() => _AddPlanScreenState();
}

class _AddPlanScreenState extends State<AddPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _totalPagesController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();

  DateTime? _targetDate;
  String _selectedUnit = 'ページ';
  int _initialDifficulty = 3;
  final List<String> _units = ['ページ', '問', '章', '個', '単元'];
  
  bool get isEditing => widget.planToEdit != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final plan = widget.planToEdit!;
      _titleController.text = plan.title;
      _totalPagesController.text = plan.totalPages.toString();
      _descriptionController.text = plan.description ?? '';
      _tagsController.text = plan.tags?.join(', ') ?? '';
      _targetDate = plan.targetDate;
      _selectedUnit = plan.unit;
      _initialDifficulty = plan.initialDifficulty ?? 3;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _totalPagesController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _targetDate) {
      setState(() => _targetDate = picked);
    }
  }
  
  void _savePlan() {
    final bool isValid = _formKey.currentState!.validate();
    if (!isValid || _targetDate == null) {
      if (_targetDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('目標日を選択してください。'), backgroundColor: Colors.red)
        );
      }
      return;
    }

    final tags = _tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    if (isEditing) {
      final plan = widget.planToEdit!;
      plan.title = _titleController.text;
      plan.totalPages = int.parse(_totalPagesController.text);
      plan.description = _descriptionController.text;
      plan.tags = tags;
      plan.targetDate = _targetDate!;
      plan.unit = _selectedUnit;
      plan.initialDifficulty = _initialDifficulty;
      PlanService.updatePlan(plan);
    } else {
      final newPlan = StudyPlan(
        id: const Uuid().v4(),
        title: _titleController.text,
        totalPages: int.parse(_totalPagesController.text),
        targetDate: _targetDate!,
        creationDate: DateTime.now(),
        records: HiveList(PlanService.getRecordsBox()),
        unit: _selectedUnit,
        description: _descriptionController.text,
        tags: tags,
        initialDifficulty: _initialDifficulty,
      );
      PlanService.addPlan(newPlan);
    }
    
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? '計画を編集' : '計画を新規作成')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '参考書タイトル'),
              validator: (value) => (value == null || value.isEmpty) ? 'タイトルを入力してください' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: '説明（任意）'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _totalPagesController,
                    decoration: const InputDecoration(labelText: '総量'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return '数値を入力';
                      if (int.tryParse(value) == null) return '有効な数値を入力';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 120,
                  child: DropdownButtonFormField<String>(
                    value: _selectedUnit,
                    decoration: const InputDecoration(labelText: '単位'),
                    items: _units.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                    onChanged: (newValue) => setState(() => _selectedUnit = newValue!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(labelText: 'タグ（カンマ区切り、任意）'),
            ),
            const SizedBox(height: 24),
            _buildRatingSelector('初期難易度', 5, _initialDifficulty, (rating) => setState(() => _initialDifficulty = rating)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _targetDate == null ? '目標日が選択されていません' : '目標日: ${_targetDate!.toLocal().toString().split(' ')[0]}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('日付を選択'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _savePlan,
              child: Text(isEditing ? '更新する' : 'この内容で保存する'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSelector(String title, int count, int selectedValue, ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(count, (index) {
            final value = index + 1;
            return IconButton(
              icon: Icon(value <= selectedValue ? Icons.star : Icons.star_border, color: Colors.amber, size: 32),
              onPressed: () => onChanged(value),
            );
          }),
        ),
      ],
    );
  }
}