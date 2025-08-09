import 'package:meta/meta.dart';

/// Represents a user's study plan for a specific subject or goal.
@immutable
class StudyPlan {
  /// The unique identifier for the study plan.
  final String id;

  /// The ID of the user who owns this plan.
  final String userId;

  /// The title of the study plan (e.g., "Calculus I Exam Prep").
  final String title;

  /// The total number of units to be studied (e.g., pages, problems).
  final int totalUnits;

  /// The date the plan was created.
  final DateTime createdAt;

  /// The original deadline to complete the plan.
  final DateTime deadline;

  /// The number of review rounds.
  final int rounds;

  /// The suggested number of units to study per day.
  final int? dailyQuota;

  /// The dynamically adjusted deadline based on progress.
  final DateTime? dynamicDeadline;

  /// Creates a new [StudyPlan] instance.
  StudyPlan({
    required this.id,
    required this.userId,
    required this.title,
    required this.totalUnits,
    required this.createdAt,
    required this.deadline,
    this.rounds = 1,
    this.dailyQuota,
    this.dynamicDeadline,
  });

  /// Creates a copy of this [StudyPlan] but with the given fields replaced with
  /// the new values.
  StudyPlan copyWith({
    String? id,
    String? userId,
    String? title,
    int? totalUnits,
    DateTime? createdAt,
    DateTime? deadline,
    int? rounds,
    int? dailyQuota,
    DateTime? dynamicDeadline,
  }) {
    return StudyPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      totalUnits: totalUnits ?? this.totalUnits,
      createdAt: createdAt ?? this.createdAt,
      deadline: deadline ?? this.deadline,
      rounds: rounds ?? this.rounds,
      dailyQuota: dailyQuota ?? this.dailyQuota,
      dynamicDeadline: dynamicDeadline ?? this.dynamicDeadline,
    );
  }
}
