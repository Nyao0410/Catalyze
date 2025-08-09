/// Represents a single study session record.
class StudyRecord {
  /// The unique identifier for the study record.
  final String id;

  /// The ID of the study plan this record belongs to.
  final String planId;

  /// The date and time the study session occurred.
  final DateTime date;

  /// The number of units completed in this session.
  final int unitsCompleted;

  /// The duration of the study session.
  final Duration duration;

  /// Creates a new [StudyRecord] instance.
  StudyRecord({
    required this.id,
    required this.planId,
    required this.date,
    required this.unitsCompleted,
    required this.duration,
  });
}
