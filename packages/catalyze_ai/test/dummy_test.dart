import 'package:catalyze_ai/algorithms/dynamic_quota.dart';
import 'package:test/test.dart';

void main() {
  group('Catalyze AI Package', () {
    test('can be loaded and basic algorithm can be called', () {
      // This test confirms that the package is correctly set up and its
      // components are accessible.
      final result = dynamicQuotaAlgorithm(
        remainingUnits: 100,
        daysUntilDeadline: 10,
        recentPace: 8.0,
        achievementRate: 0.2,
        now: DateTime.now(),
      );

      // A simple assertion to ensure the function runs without errors.
      expect(result, isA<QuotaResult>());
      expect(result.dailyQuota, isA<int>());
      expect(result.dynamicDeadline, isA<DateTime>());
    });
  });
}
