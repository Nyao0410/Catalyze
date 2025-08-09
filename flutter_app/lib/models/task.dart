import 'package:flutter/foundation.dart';

/// A simple model representing a task for the user to complete.
@immutable
class Task {
  final String title;
  final String description;

  const Task({required this.title, required this.description});
}
