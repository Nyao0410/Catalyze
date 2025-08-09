import '../models/study_plan.dart';
import '../models/study_record.dart';
import '../models/user.dart';

/// Abstract interface for data persistence.
///
/// This defines the contract for fetching and saving study-related data,
/// allowing for interchangeable implementations (e.g., in-memory, Firebase).
abstract class Repository {
  /// Retrieves a user by their ID.
  Future<User> getUser(String userId);

  /// Retrieves a study plan by its ID.
  Future<StudyPlan> getStudyPlan(String planId);

  /// Retrieves all study records for a given plan.
  Future<List<StudyRecord>> getStudyRecordsForPlan(String planId);

  /// Saves a new or updated study plan.
  Future<void> saveStudyPlan(StudyPlan plan);

  /// Saves a new study record.
  Future<void> saveStudyRecord(StudyRecord record);
}
