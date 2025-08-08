import 'package:catalyze/src/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:catalyze/src/constants/app_sizes.dart';
import 'package:catalyze/src/features/plan/models/study_plan.dart';
import 'package:catalyze/src/features/plan/services/plan_service.dart';
import 'package:catalyze/src/common_widgets/primary_button.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlanCreationScreen extends StatefulWidget {
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
  String? _unit; // String? に変更
  late int _predictedPt;
  late DateTime _deadline;
  late String _description;
  late int _priority;
  late bool _isActive;
  // ------------------

  final List<String> _defaultUnits = ['ページ', '問', '章'];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.plan != null;
    _title = widget.plan?.title ?? '';
    _totalAmount = widget.plan?.totalAmount ?? 0;
    _unit = widget.plan?.unit; // 初期値は既存の単位、なければnull
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
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    if (_unit == null || _unit!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.planSelectUnitError)),
      );
      return;
    }

    final planData = StudyPlan(
      id: widget.plan?.id ?? const Uuid().v4(),
      title: _title,
      totalAmount: _totalAmount,
      createdAt: widget.plan?.createdAt ?? Timestamp.now(),
      unit: _unit!, // nullチェック
      deadline: Timestamp.fromDate(_deadline),
      priority: _priority,
      isActive: _isActive,
      completedAmount: widget.plan?.completedAmount ?? 0,
    );

    final future = _isEditing
        ? _planService.updatePlan(planData)
        : _planService.addPlan(planData);

    future.then((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? AppStrings.planEdit : AppStrings.planCreation)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(p16),
          children: [
            TextFormField(
              initialValue: _title,
              decoration: const InputDecoration(labelText: AppStrings.planTitle),
              validator: (value) => value!.isEmpty ? AppStrings.pleaseInput : null,
              onSaved: (value) => _title = value!,
            ),
            gapH16,
            TextFormField(
              initialValue: _description,
              decoration: const InputDecoration(labelText: AppStrings.planDescription),
              onSaved: (value) => _description = value ?? '',
            ),
            gapH16,
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _totalAmount.toString(),
                    decoration: const InputDecoration(labelText: AppStrings.planTotalAmount),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? AppStrings.pleaseInput : null,
                    onSaved: (value) => _totalAmount = int.parse(value!),
                  ),
                ),
                gapW16,
                Expanded(
                  child: StreamBuilder<List<String>>(
                    stream: _planService.getCustomUnits(),
                    builder: (context, snapshot) {
                      final customUnits = snapshot.data ?? [];
                      final allUnits = [..._defaultUnits, ...customUnits];
                      return DropdownButtonFormField<String>(
                        value: _unit,
                        hint: const Text(AppStrings.planSelectUnit),
                        decoration: const InputDecoration(labelText: AppStrings.planUnit),
                        validator: (value) => value == null || value.isEmpty ? AppStrings.pleaseSelect : null,
                        onChanged: (String? newValue) {
                          setState(() {
                            _unit = newValue;
                          });
                        },
                        items: allUnits.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onSaved: (value) => _unit = value,
                      );
                    },
                  ),
                ),
              ],
            ),
            gapH16,
            TextFormField(
              initialValue: _predictedPt.toString(),
              decoration: const InputDecoration(labelText: AppStrings.planPredictedPt),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? AppStrings.pleaseInput : null,
              onSaved: (value) => _predictedPt = int.parse(value!), 
            ),
            gapH24,
            const Text(AppStrings.planInitialDifficulty, style: TextStyle(fontSize: 16)),
            _StarRating(
              rating: _priority, // priorityを難易度として使用
              onRatingChanged: (rating) => setState(() => _priority = rating),
            ),
            gapH24,
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${AppStrings.planSelectDate}: ${DateFormat('yyyy/MM/dd').format(_deadline)}',
                  ),
                ),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: const Text(AppStrings.planSelectDate),
                ),
              ],
            ),
            gapH32,
            PrimaryButton(onPressed: _savePlan, text: _isEditing ? AppStrings.update : AppStrings.save),
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
