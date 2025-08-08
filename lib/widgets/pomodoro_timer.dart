import 'dart:async';
import 'package:flutter/material.dart';
import 'package:study_ai_assistant/constants/app_sizes.dart';
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
  static const int _workDuration = 5; // For testing: 5 seconds
  static const int _breakDuration = 3; // For testing: 3 seconds

  final PlanService _planService = PlanService();
  Timer? _timer;
  int _remainingSeconds = _workDuration;
  PomodoroState _currentState = PomodoroState.initial;

  void _startTimer() {
    setState(() => _currentState = PomodoroState.running);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      }
      else {
        _timer?.cancel();
        if (_currentState == PomodoroState.running) {
          _showRecordDialog();
          setState(() {
            _currentState = PomodoroState.breakTime;
            _remainingSeconds = _breakDuration;
          });
          _startTimer();
        }
        else {
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
    setState(() => _currentState = PomodoroState.paused);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _currentState = PomodoroState.initial;
      _remainingSeconds = _workDuration;
    });
  }

  Future<void> _showRecordDialog() async {
    double pagesCompleted = 1;
    int difficulty = 3;
    int concentration = 2;

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
                    Text('今回進んだ${widget.plan.unit}数: ${pagesCompleted.round()}'),
                    Slider(
                      value: pagesCompleted,
                      min: 0,
                      max: 100, // TODO: 動的に設定
                      divisions: 100,
                      label: pagesCompleted.round().toString(),
                      onChanged: (value) => setStateInDialog(() => pagesCompleted = value),
                    ),
                    gapH16,
                    const Text('難易度'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) => IconButton(
                        onPressed: () => setStateInDialog(() => difficulty = index + 1),
                        icon: Icon(index < difficulty ? Icons.star : Icons.star_border, color: Colors.amber),
                      )),
                    ),
                    gapH16,
                    const Text('集中度'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(3, (index) {
                        final isSelected = concentration == index + 1;
                        final emojis = ['☹️', '😐', '😁']; // 絵文字を修正
                        return GestureDetector(
                          onTap: () => setStateInDialog(() => concentration = index + 1),
                          child: Opacity(
                            opacity: isSelected ? 1.0 : 0.5,
                            child: Text(emojis[index], style: const TextStyle(fontSize: 32)),
                          ),
                        );
                      }),
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
                      pagesCompleted: pagesCompleted.round(),
                      difficulty: difficulty,
                      concentration: concentration,
                      actualPt: 1,
                    );
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
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(
          _formattedTime,
          style: Theme.of(context).textTheme.displayLarge,
        ),
        gapH24,
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
