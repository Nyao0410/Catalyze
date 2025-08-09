import '../models/study_plan.dart';
import '../models/study_record.dart';
import '../models/user.dart';
import 'repository.dart';

const int _currentSchemaVersion = 2; // Define the current schema version

/// A simple, in-memory implementation of the [Repository] interface.
///
/// Useful for testing, prototyping, or offline scenarios. Data is not persisted
/// across application restarts.
class InMemoryRepository implements Repository {
  final Map<String, User> _users = {};
  final Map<String, StudyPlan> _plans = {};
  final Map<String, List<StudyRecord>> _records = {};

  InMemoryRepository(); // Removed const

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
    final fetchedPlan = _plans[planId];
    if (fetchedPlan == null) {
      throw Exception('StudyPlan with id $planId not found.');
    }

    // Apply migration if necessary
    if (fetchedPlan.schemaVersion < _currentSchemaVersion) {
      return _migratePlan(fetchedPlan, _currentSchemaVersion);
    }
    return fetchedPlan;
  }

  /// Migrates a [StudyPlan] from an older schema version to the current one.
  StudyPlan _migratePlan(StudyPlan oldPlan, int targetVersion) {
    StudyPlan migratedPlan = oldPlan;

    // Migration from v1 to v2: Add 'isArchived' field
    if (oldPlan.schemaVersion < 2 && targetVersion >= 2) {
      migratedPlan = migratedPlan.copyWith(
        isArchived: false, // Default value for new field
        schemaVersion: 2,
      );
    }
    // Add more migration steps here for future schema versions

    return migratedPlan;
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
