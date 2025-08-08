import 'dart:async';
import 'package:flutter/material.dart';
import 'package:study_ai_assistant/models/learning_record.dart';
import 'package:study_ai_assistant/models/study_plan.dart';
import 'package:study_ai_assistant/services/plan_service.dart';
import 'package:uuid/uuid.dart';

enum PomodoroState { initial, running, paused, breakTime }

class PomodoroTimer extends StatefulWidget {
  final StudyPlan plan;
  const PomodoroTimer({super.key, required this.plan});

  @override
  State<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> {
  static const int _workDuration = 25 * 60; // 25 minutes
  static const int _breakDuration = 5 * 60; // 5 minutes

  final PlanService _planService = PlanService();
  Timer? _timer;
  int _remainingSeconds = _workDuration;
  PomodoroState _currentState = PomodoroState.initial;

  void _startTimer() {
    setState(() {
      _currentState = PomodoroState.running;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        if (_currentState == PomodoroState.running) {
          _showRecordDialog();
          setState(() {
            _currentState = PomodoroState.breakTime;
            _remainingSeconds = _breakDuration;
          });
          _startTimer(); // Start break timer
        } else {
          setState(() {
            _currentState = PomodoroState.initial;
            _remainingSeconds = _workDuration;
          });
        }
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _currentState = PomodoroState.paused;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _currentState = PomodoroState.initial;
      _remainingSeconds = _workDuration;
    });
  }

  Future<void> _showRecordDialog() async {
    final pagesController = TextEditingController();
    double difficulty = 3;
    double concentration = 2;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              title: const Text('学習セッション完了！'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('今回の学習内容を記録しましょう。'),
                    const SizedBox(height: 16),
                    TextField(
                      controller: pagesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: '進んだ${widget.plan.unit}数'),
                    ),
                    const SizedBox(height: 16),
                    Text('難易度 (1:易 ~ 5:難): ${difficulty.round()}'),
                    Slider(
                      value: difficulty,
                      min: 1, max: 5, divisions: 4,
                      label: difficulty.round().toString(),
                      onChanged: (value) => setStateInDialog(() => difficulty = value),
                    ),
                    const SizedBox(height: 8),
                    Text('集中度 (1:低 ~ 3:高): ${concentration.round()}'),
                    Slider(
                      value: concentration,
                      min: 1, max: 3, divisions: 2,
                      label: concentration.round().toString(),
                      onChanged: (value) => setStateInDialog(() => concentration = value),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    final record = LearningRecord(
                      id: const Uuid().v4(),
                      recordDate: DateTime.now(),
                      durationInSeconds: _workDuration,
                      pagesCompleted: int.tryParse(pagesController.text) ?? 0,
                      difficulty: difficulty.round(),
                      concentration: concentration.round(),
                      actualPt: 1, // 正しいフィールド名
                    );
                    // 正しい引数でメソッドを呼び出す
                    _planService.addLearningRecord(widget.plan.id, record);
                    Navigator.pop(context);
                  },
                  child: const Text('記録する'),
                )
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_remainingSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _currentState == PomodoroState.breakTime ? '休憩中...' : '集中タイム',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          _formattedTime,
          style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (_currentState == PomodoroState.initial || _currentState == PomodoroState.paused)
              ElevatedButton(onPressed: _startTimer, child: const Text('開始')),
            if (_currentState == PomodoroState.running)
              ElevatedButton(onPressed: _pauseTimer, child: const Text('一時停止')),
            ElevatedButton(onPressed: _resetTimer, child: const Text('リセット')),
          ],
        )
      ],
    );
  }
}