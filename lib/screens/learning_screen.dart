import 'dart:async';
import 'package:flutter/material.dart';
import 'package:study_ai_assistant/models/learning_record.dart';
import 'package:study_ai_assistant/models/study_plan.dart';
import 'package:study_ai_assistant/services/plan_service.dart';
import 'package:uuid/uuid.dart';

class LearningScreen extends StatefulWidget {
  final StudyPlan plan;
  const LearningScreen({super.key, required this.plan});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  int _difficulty = 3;
  int _concentration = 2;
  double _sliderValue = 0;

  late Timer _timer;
  int _durationInSeconds = 0;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    if (widget.plan.records.isNotEmpty) {
      final lastRecord = widget.plan.records.last;
      _difficulty = lastRecord.difficulty;
      _concentration = lastRecord.concentration;
    } else {
      _difficulty = widget.plan.initialDifficulty ?? 3; // Null-aware operator with default value
    }
    _sliderValue = widget.plan.dailyTarget.toDouble();
  }

  @override
  void dispose() {
    if (_isTimerRunning) _timer.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isTimerRunning) {
      _timer.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() => _durationInSeconds++);
      });
    }
    setState(() => _isTimerRunning = !_isTimerRunning);
  }

  String _formatDuration(int totalSeconds) {
    final d = Duration(seconds: totalSeconds);
    return "${d.inHours.toString().padLeft(2, '0')}:${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}";
  }

  void _saveRecord() {
    if (_isTimerRunning) _toggleTimer();

    final newRecord = LearningRecord(
      id: const Uuid().v4(),
      recordDate: DateTime.now(),
      durationInSeconds: _durationInSeconds,
      pagesCompleted: _sliderValue.round(),
      difficulty: _difficulty,
      concentration: _concentration,
    );

    PlanService.addLearningRecord(widget.plan, newRecord);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.plan.title)),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(_formatDuration(_durationInSeconds), style: Theme.of(context).textTheme.displaySmall),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _toggleTimer,
                    icon: Icon(_isTimerRunning ? Icons.pause : Icons.play_arrow),
                    label: Text(_isTimerRunning ? '一時停止' : '学習開始'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('今回進んだ${widget.plan.unit}数: ${_sliderValue.round()}', style: Theme.of(context).textTheme.titleMedium),
          Slider(
            value: _sliderValue,
            min: 0,
            max: (widget.plan.remainingPages.toDouble() + 20),
            divisions: (widget.plan.remainingPages + 20).toInt(),
            label: _sliderValue.round().toString(),
            onChanged: (double value) {
              setState(() => _sliderValue = value);
            },
          ),
          const SizedBox(height: 24),
          _buildRatingSelector('難易度', 5, _difficulty, (rating) => setState(() => _difficulty = rating)),
          const SizedBox(height: 24),
          _buildConcentrationSelector(),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _saveRecord,
            child: const Text('この学習を記録する'),
          ),
        ],
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

  Widget _buildConcentrationSelector() {
    final List<String> emojis = ['☹️', '😐', '😀'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('集中度', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(emojis.length, (index) {
            final value = index + 1;
            return GestureDetector(
              onTap: () => setState(() => _concentration = value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _concentration == value ? Colors.blue.withOpacity(0.3) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Text(emojis[index], style: TextStyle(fontSize: 32, color: _concentration == value ? null : Colors.grey)),
              ),
            );
          }),
        ),
      ],
    );
  }
}