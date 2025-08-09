import '../models/study_plan.dart';
import '../models/study_record.dart';
import '../models/user.dart';
import 'repository.dart';

/// A simple, in-memory implementation of the [Repository] interface.
///
/// Useful for testing, prototyping, or offline scenarios. Data is not persisted
/// across application restarts.
class InMemoryRepository implements Repository {
  final Map<String, User> _users = {};
  final Map<String, StudyPlan> _plans = {};
  final Map<String, List<StudyRecord>> _records = {};

  @override
  Future<User> getUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 50)); // Simulate network latency
    final user = _users[userId];
    if (user == null) {
      throw Exception('User with id $userId not found.');
    }
    return user;
  }

  @override
  Future<StudyPlan> getStudyPlan(String planId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final plan = _plans[planId];
    if (plan == null) {
      throw Exception('StudyPlan with id $planId not found.');
    }
    return plan;
  }

  @override
  Future<List<StudyRecord>> getStudyRecordsForPlan(String planId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _records[planId] ?? [];
  }

  @override
  Future<void> saveStudyPlan(StudyPlan plan) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _plans[plan.id] = plan;
  }

  @override
  Future<void> saveStudyRecord(StudyRecord record) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final recordsForPlan = _records.putIfAbsent(record.planId, () => []);
    recordsForPlan.add(record);
  }
}
