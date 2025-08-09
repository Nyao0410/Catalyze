/// Represents a scheduled review for a specific topic or unit.
class ReviewSchedule {
  /// The unique identifier for the review schedule.
  final String id;

  /// The ID of the study plan this review belongs to.
  final String planId;

  /// The specific topic or unit to be reviewed.
  final String topic;

  /// The scheduled date for the review.
  final DateTime reviewDate;

  /// Creates a new [ReviewSchedule] instance.
  ReviewSchedule({
    required this.id,
    required this.planId,
    required this.topic,
    required this.reviewDate,
  });
}
