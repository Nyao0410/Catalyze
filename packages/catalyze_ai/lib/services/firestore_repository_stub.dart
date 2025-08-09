import 'package:catalyze_ai/catalyze_ai.dart';

/// A stub implementation of the [Repository] interface for Firestore.
///
/// This class provides the method signatures for a Firestore-backed repository,
/// allowing for future implementation while maintaining interface compatibility.
/// All methods currently throw [UnimplementedError].
class FirestoreRepository implements Repository {
  @override
  Future<User> getUser(String userId) {
    throw UnimplementedError('getUser has not been implemented for FirestoreRepository.');
  }

  @override
  Future<StudyPlan> getStudyPlan(String planId) {
    throw UnimplementedError('getStudyPlan has not been implemented for FirestoreRepository.');
  }

  @override
  Future<List<StudyRecord>> getStudyRecordsForPlan(String planId) {
    throw UnimplementedError('getStudyRecordsForPlan has not been implemented for FirestoreRepository.');
  }

  @override
  Future<void> saveStudyPlan(StudyPlan plan) {
    throw UnimplementedError('saveStudyPlan has not been implemented for FirestoreRepository.');
  }

  @override
  Future<void> saveStudyRecord(StudyRecord record) {
    throw UnimplementedError('saveStudyRecord has not been implemented for FirestoreRepository.');
  }
}
