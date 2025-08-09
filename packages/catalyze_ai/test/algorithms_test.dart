import 'package:catalyze_ai/algorithms/dynamic_quota.dart';
import 'package:catalyze_ai/algorithms/planning_algorithms.dart';
import 'package:catalyze_ai/models/study_plan.dart';
import 'package:catalyze_ai/models/study_record.dart';
import 'package:test/test.dart';

void main() {
  group('dynamicQuotaAlgorithm', () {
    final now = DateTime.now();

    test('returns 0 quota for 0 remaining units', () {
      final result = dynamicQuotaAlgorithm(
        remainingUnits: 0,
        daysUntilDeadline: 10,
        recentPace: 10,
        achievementRate: 1.0,
        now: now,
      );
      expect(result.dailyQuota, 0);
    });

    test('calculates basic quota correctly', () {
      final result = dynamicQuotaAlgorithm(
        remainingUnits: 100,
        daysUntilDeadline: 10,
        recentPace: 10,
        achievementRate: 1.0, // Normal achievement
        now: now,
      );
      expect(result.dailyQuota, 10); // 100 / 10
    });

    test('decreases quota for high achievement rate', () {
      final result = dynamicQuotaAlgorithm(
        remainingUnits: 100,
        daysUntilDeadline: 10,
        recentPace: 10,
        achievementRate: 1.3, // High achievement
        now: now,
      );
      expect(result.dailyQuota, 9); // 10 - 1
    });

    test('increases quota for low achievement rate', () {
      final result = dynamicQuotaAlgorithm(
        remainingUnits: 100,
        daysUntilDeadline: 10,
        recentPace: 5,
        achievementRate: 0.7, // Low achievement
        now: now,
      );
      expect(result.dailyQuota, 11); // 10 + 1
    });

    test('shortens deadline for very high recent pace', () {
      final result = dynamicQuotaAlgorithm(
        remainingUnits: 100,
        daysUntilDeadline: 10,
        recentPace: 20, // basic quota is 10, pace is > 10 * 1.2
        achievementRate: 1.1,
        now: now,
      );
      // final daysNeededNormally = (100 / 10).ceil(); // 10 - Removed unused variable
      // final expectedDeadline = now.add(Duration(days: daysNeededNormally)); - Removed unused variable

      // days with pace = ceil(100/20) = 5. diff = 10-5=5. reduction=ceil(5*0.25)=2
      // new deadline = now + 10 - 2 = now + 8 days.
      final reducedDeadline = now.add(const Duration(days: 8));

      expect(result.dynamicDeadline.day, reducedDeadline.day);
    });

     test('handles 1 day until deadline', () {
      final result = dynamicQuotaAlgorithm(
        remainingUnits: 10,
        daysUntilDeadline: 1,
        recentPace: 1,
        achievementRate: 0.5,
        now: now,
      );
      // basic = 10. low achievement -> quota = 11
      expect(result.dailyQuota, 11);
    });
  });

  group('recomputeDynamicQuota', () {
    final now = DateTime(2023, 10, 11);
    final plan = StudyPlan(
      id: '1',
      userId: 'u1',
      title: 'Test Plan',
      totalUnits: 100,
      createdAt: DateTime(2023, 10, 1),
      deadline: DateTime(2023, 10, 31), // 30 days total
      schemaVersion: 2, // Added schemaVersion
    );

    test('for a new plan with no records', () {
      final result = recomputeDynamicQuota(plan, [], now);
      // elapsed=10, total=30. expected=100*(10/30)=33.3. actual=0. rate=0.
      // remaining=100. daysUntil=20. basic=100/20=5. rate<0.8 -> quota=6
      expect(result.dailyQuota, 6);
    });

    test('for a plan that is behind schedule', () {
      final records = [
        StudyRecord(id: 'r1', planId: '1', date: DateTime(2023, 10, 5), unitsCompleted: 10, duration: const Duration(hours: 1)),
      ]; // completed 10. expected ~33. rate = 10/33.3 = ~0.3 < 0.8
      final result = recomputeDynamicQuota(plan, records, now);
      // remaining=90. daysUntil=20. basic=ceil(90/20)=5. rate<0.8 -> quota=6
      expect(result.dailyQuota, 6);
    });

     test('for a plan that is ahead of schedule', () {
       final records = List.generate(6, (i) => StudyRecord(id: 'r$i', planId: '1', date: now.subtract(Duration(days: 7-i)), unitsCompleted: 10, duration: const Duration(hours: 1)));
       // completed 60. expected ~33. rate = 60/33.3 = ~1.8 > 1.2
       final result = recomputeDynamicQuota(plan, records, now);
       // remaining=40. daysUntil=20. basic=ceil(40/20)=2. rate>1.2 -> quota=1
       expect(result.dailyQuota, 1);
    });
  });

  group('generateReviewSchedules', () {
    final completedAt = DateTime(2023, 1, 1);

    test('generates standard intervals for quality 3', () {
      final dates = generateReviewSchedules(completedAt, 3); // Updated call
      expect(dates, [
        DateTime(2023, 1, 2), // +1 day
        DateTime(2023, 1, 8), // +7 days
        DateTime(2023, 1, 31), // +30 days
        DateTime(2023, 4, 1), // +90 days
      ]);
    });

    test('extends intervals for quality 5', () {
      final dates = generateReviewSchedules(completedAt, 5); // Updated call
      expect(dates, [
        DateTime(2023, 1, 2), // 1*1.2=1.2 -> 1 day
        DateTime(2023, 1, 9), // 7*1.2=8.4 -> 8 days
        DateTime(2023, 2, 6), // 30*1.2=36 -> 36 days
        DateTime(2023, 4, 19), // 90*1.2=108 -> 108 days
      ]);
    });

    test('shortens intervals for quality 1', () {
      final dates = generateReviewSchedules(completedAt, 1); // 0.8x multiplier
      expect(dates, [
        DateTime(2023, 1, 2), // 1*0.8=0.8 -> 1 day
        DateTime(2023, 1, 7), // 7*0.8=5.6 -> 6 days
        DateTime(2023, 1, 25), // 30*0.8=24 -> 24 days
        DateTime(2023, 3, 14), // 90*0.8=72 -> 72 days
      ]);
    });
  });

  group('allocateRounds', () {
    final plan = StudyPlan(
      id: '1',
      userId: 'u1',
      title: 'Test',
      totalUnits: 100,
      createdAt: DateTime(2023, 1, 1),
      deadline: DateTime(2023, 1, 31), // 30 days
      schemaVersion: 2, // Added schemaVersion
    );

    test('divides days evenly', () {
      final allocation = allocateRounds(plan.copyWith(rounds: 3)); // Updated call
      expect(allocation, {1: 10, 2: 10, 3: 10});
    });

    test('handles remainders correctly', () {
      final allocation = allocateRounds(plan.copyWith(rounds: 4, deadline: DateTime(2023, 1, 30))); // Updated call
      // 29/4 = 7 rem 1
      expect(allocation, {1: 8, 2: 7, 3: 7, 4: 7});
    });

    test('works for a single round', () {
      final allocation = allocateRounds(plan.copyWith(rounds: 1)); // Updated call
      expect(allocation, {1: 30});
    });

     test('returns empty map for 0 rounds', () {
      final allocation = allocateRounds(plan.copyWith(rounds: 0)); // Updated call
      expect(allocation, {});
    });
  });
}