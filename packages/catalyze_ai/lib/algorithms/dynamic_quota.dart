import 'dart:math';
import 'package:meta/meta.dart';

/// A Data Transfer Object (DTO) for the result of the dynamic quota algorithm.
@immutable
class QuotaResult {
  /// The recommended number of units to study today.
  final int dailyQuota;

  /// The dynamically adjusted deadline based on current progress.
  final DateTime dynamicDeadline;

  /// Creates a [QuotaResult].
  const QuotaResult({required this.dailyQuota, required this.dynamicDeadline});
}

/// Calculates a dynamic daily study quota based on progress and deadlines.
///
/// This pure function adjusts the study plan to be more realistic and achievable.
///
/// - [remainingUnits]: The number of units left to study.
/// - [daysUntilDeadline]: The number of days remaining until the original deadline.
/// - [recentPace]: The user's average study pace (units per day) over a recent period.
/// - [achievementRate]: A measure of progress against the schedule.
///   (e.g., 1.0 is on-track, >1.0 is ahead, <1.0 is behind).
/// - [now]: The current date, for calculating the new deadline.
///
/// Returns a [QuotaResult] with the suggested daily quota and a new dynamic deadline.
QuotaResult dynamicQuotaAlgorithm({
  required int remainingUnits,
  required int daysUntilDeadline,
  required double recentPace,
  required double achievementRate,
  required DateTime now,
}) {
  if (remainingUnits <= 0) {
    return QuotaResult(dailyQuota: 0, dynamicDeadline: now);
  }

  final effectiveDays = max(1, daysUntilDeadline);
  final basicQuota = (remainingUnits / effectiveDays).ceil();
  int finalQuota;

  if (achievementRate >= 1.2) {
    finalQuota = max(1, basicQuota - 1);
  } else if (achievementRate < 0.8) {
    finalQuota = basicQuota + 1;
  } else {
    finalQuota = basicQuota;
  }

  final daysNeededForQuota = (remainingUnits / finalQuota).ceil();
  DateTime dynamicDeadline = now.add(Duration(days: daysNeededForQuota));

  // If recent pace is significantly faster, pull the deadline in.
  if (recentPace > basicQuota * 1.2 && recentPace > 0) {
    final daysNeededWithPace = (remainingUnits / recentPace).ceil();
    final dayDifference = daysNeededForQuota - daysNeededWithPace;
    if (dayDifference > 0) {
      final reduction = (dayDifference * 0.25).ceil();
      dynamicDeadline = dynamicDeadline.subtract(Duration(days: reduction));
    }
  }

  return QuotaResult(
    dailyQuota: finalQuota,
    dynamicDeadline: dynamicDeadline,
  );
}
