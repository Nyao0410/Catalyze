import 'dart:math';

import '../models/study_plan.dart';
import '../models/study_record.dart';
import 'dynamic_quota.dart';

/// Recomputes the dynamic daily quota and deadline for a study plan.
///
/// This is a pure function; it returns a new [QuotaResult] rather than
/// modifying the plan.
///
/// - [plan]: The user's study plan.
/// - [records]: The list of all study records for this plan.
/// - [now]: The current date, for calculations.
///
/// Returns a [QuotaResult] with the updated daily quota and dynamic deadline.
QuotaResult recomputeDynamicQuota(
  StudyPlan plan,
  List<StudyRecord> records,
  DateTime now,
) {
  final totalCompletedUnits = records.fold<int>(
    0,
    (sum, record) => sum + record.unitsCompleted,
  );
  final remainingUnits = plan.totalUnits - totalCompletedUnits;

  if (remainingUnits <= 0) {
    return QuotaResult(dailyQuota: 0, dynamicDeadline: now);
  }

  final daysUntilDeadline = plan.deadline.difference(now).inDays;

  // Calculate recent pace from the last 7 days of records.
  final sevenDaysAgo = now.subtract(const Duration(days: 7));
  final recentRecords = records.where((r) => r.date.isAfter(sevenDaysAgo)).toList();
  final double recentUnits = recentRecords.fold<double>(0.0, (sum, r) => sum + r.unitsCompleted);
  final double recentPace = recentRecords.isNotEmpty ? recentUnits / 7.0 : 0.0;

  // Calculate achievement rate.
  final daysElapsed = now.difference(plan.createdAt).inDays;
  final totalPlanDays = plan.deadline.difference(plan.createdAt).inDays;
  double achievementRate = 1.0;
  if (totalPlanDays > 0 && daysElapsed > 0) {
    final expectedUnits = plan.totalUnits * (daysElapsed / totalPlanDays);
    if (expectedUnits > 0) {
      achievementRate = totalCompletedUnits / expectedUnits;
    }
  }

  return dynamicQuotaAlgorithm(
    remainingUnits: remainingUnits,
    daysUntilDeadline: daysUntilDeadline,
    recentPace: recentPace,
    achievementRate: achievementRate,
    now: now,
  );
}

/// Generates a list of review dates based on the Spaced Repetition principle.
///
/// - [completedAt]: The date an item was successfully studied.
/// - [quality]: A rating of how well the item was remembered (e.g., 1-5).
///
/// Returns a list of future [DateTime]s for review.
List<DateTime> generateReviewSchedules(DateTime completedAt, int quality) {
  const baseIntervals = [1, 7, 30, 90]; // in days

  // Quality factor: 3 is baseline, 5 is best (+20%), 1 is worst (-20%)
  final multiplier = 1.0 + (quality - 3) * 0.1;

  return baseIntervals
      .map((interval) => completedAt.add(Duration(days: (interval * multiplier).round())))
      .toList();
}

/// Allocates the total days of a study plan across a number of rounds.
///
/// - [plan]: The study plan.
///
/// Returns a map where the key is the round number (1-based) and the value
/// is the number of days allocated to that round.
Map<int, int> allocateRounds(StudyPlan plan) {
  if (plan.rounds <= 0) return {};

  final totalDays = plan.deadline.difference(plan.createdAt).inDays;
  if (totalDays <= 0) return {};

  final daysPerRound = totalDays ~/ plan.rounds;
  final remainder = totalDays % plan.rounds;

  final allocation = <int, int>{};
  for (int i = 1; i <= plan.rounds; i++) {
    allocation[i] = daysPerRound;
  }

  // Distribute the remainder among the first rounds
  for (int i = 1; i <= remainder; i++) {
    allocation[i] = allocation[i]! + 1;
  }

  return allocation;
}