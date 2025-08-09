/// Represents calculated performance metrics for a study plan.
class Metrics {
  /// The average number of units completed per day.
  final double pace;

  /// The percentage of the study plan that has been completed.
  final double achievementRate;

  /// The projected completion date based on the current pace.
  final DateTime projectedCompletionDate;

  /// Creates a new [Metrics] instance.
  Metrics({
    required this.pace,
    required this.achievementRate,
    required this.projectedCompletionDate,
  });
}
