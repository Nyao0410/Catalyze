import 'dart:async';
import 'package:flutter/material.dart';
import 'package:catalyze/constants/app_sizes.dart';
import 'package:catalyze/models/study_plan.dart';

enum PomodoroState { initial, running, paused, breakTime }

class PomodoroTimer extends StatefulWidget {
  final StudyPlan plan;
  final bool autostart;
  final Function(int ptCount, Duration duration)? onTimerEnd;

  const PomodoroTimer({super.key, required this.plan, this.autostart = false, this.onTimerEnd});

  @override
  State<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> {
  static const int _workDuration = 25 * 60; // 25 minutes
  static const int _breakDuration = 5 * 60; // 5 minutes

  Timer? _timer;
  int _remainingSeconds = _workDuration;
  PomodoroState _currentState = PomodoroState.initial;
  int _ptCount = 0; // ポモドーロ完了回数を追跡

  @override
  void initState() {
    super.initState();
    if (widget.autostart) {
      _startTimer();
    }
  }

  void _startTimer() {
    setState(() => _currentState = PomodoroState.running);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      }
      else {
        _timer?.cancel();
        if (_currentState == PomodoroState.running) {
          _ptCount++;
          widget.onTimerEnd?.call(_ptCount, const Duration(minutes: 25)); // 25分固定で渡す
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
            _ptCount = 0; // リセット時にPTカウントもリセット
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
      _ptCount = 0; // リセット時にPTカウントもリセット
    });
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
