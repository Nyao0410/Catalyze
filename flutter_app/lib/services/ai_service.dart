import 'package:catalyze_ai/catalyze_ai.dart';
import '../models/task.dart';

/// A service to interact with the catalyze_ai logic.
class AIService {
  final Repository _repository;

  /// Creates an AIService.
  ///
  /// An optional [Repository] can be provided for dependency injection,
  /// otherwise a default [InMemoryRepository] is created.
  AIService({Repository? repository}) : _repository = repository ?? InMemoryRepository(); // Removed const from AIService constructor

  /// In a real app, you'd have a way to get the current user's plans.
  /// For this example, we'll assume the user has one plan.
  /// This method would fetch all plans for the user.
  Future<StudyPlan?> _getPrimaryStudyPlan(String userId) async {
    // This is a simplified lookup. A real implementation would query
    // the repository for plans associated with the userId.
    try {
      // Let's assume plan 'p1' is the user's primary plan.
      return await _repository.getStudyPlan('p1');
    } catch (e) {
      return null;
    }
  }

  /// Fetches the daily tasks for a given user.
  Future<List<Task>> fetchDailyTasks(String userId) async {
    final plan = await _getPrimaryStudyPlan(userId);
    if (plan == null) {
      return const [Task(title: 'No study plan found', description: 'Create a new study plan to get started.')];
    }

    final records = await _repository.getStudyRecordsForPlan(plan.id);
    final now = DateTime.now();

    final quotaResult = recomputeDynamicQuota(plan, records, now);

    if (quotaResult.dailyQuota <= 0) {
      return const [Task(title: 'All caught up!', description: 'You have completed your study plan. Great job!')];
    }

    return [
      Task(
        title: 'Study ${plan.title}',
        description: 'Complete ${quotaResult.dailyQuota} units today.',
      ),
      const Task( // Added const
        title: 'Review Session',
        description: 'Review previous topics based on your schedule.',
      ),
    ];
  }

  // Helper to seed data for tests and previews.
  Repository get repository => _repository;
}

