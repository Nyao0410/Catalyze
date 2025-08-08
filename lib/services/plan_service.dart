import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_ai_assistant/models/study_plan.dart';
import 'package:study_ai_assistant/models/learning_record.dart';

class PlanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ログインしているユーザーのIDを取得するヘルパー
  String? get _userId => _auth.currentUser?.uid;

  // ユーザー専用の'study_plans'コレクションへの参照を返す
  CollectionReference<StudyPlan> _getStudyPlansRef() {
    final userId = _userId;
    if (userId == null) {
      throw Exception("User not logged in");
    }
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('study_plans')
        .withConverter<StudyPlan>(
          fromFirestore: (snapshot, _) => StudyPlan.fromMap(snapshot.data()!),
          toFirestore: (plan, _) => plan.toMap(),
        );
  }

  // ユーザー専用の学習計画をストリームとして取得
  Stream<List<StudyPlan>> getStudyPlans() {
    if (_userId == null) return Stream.value([]); // 未ログイン時は空のリストを返す
    return _getStudyPlansRef().orderBy('creationDate', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // 学習計画の追加
  Future<void> addStudyPlan(StudyPlan plan) {
    return _getStudyPlansRef().doc(plan.id).set(plan);
  }

  // 学習計画の更新
  Future<void> updateStudyPlan(StudyPlan plan) {
    return _getStudyPlansRef().doc(plan.id).update(plan.toMap());
  }

  // 学習計画の削除
  Future<void> deleteStudyPlan(String planId) {
    return _getStudyPlansRef().doc(planId).delete();
  }

  // --- 学習記録（LearningRecord）用のメソッド ---

  // ユーザー専用の'learning_records'サブコレクションへの参照
  CollectionReference<LearningRecord> _getLearningRecordsRef(String planId) {
     final userId = _userId;
    if (userId == null) {
      throw Exception("User not logged in");
    }
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('study_plans')
        .doc(planId)
        .collection('learning_records')
        .withConverter<LearningRecord>(
            fromFirestore: (snapshot, _) => LearningRecord.fromMap(snapshot.data()!),
            toFirestore: (record, _) => record.toMap(),
          );
  }

  // 学習記録をストリームとして取得
  Stream<List<LearningRecord>> getLearningRecords(String planId) {
    if (_userId == null) return Stream.value([]);
    return _getLearningRecordsRef(planId).orderBy('recordDate', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // 学習記録の追加
  Future<void> addLearningRecord(String planId, LearningRecord record) {
    return _getLearningRecordsRef(planId).doc(record.id).set(record);
  }
}