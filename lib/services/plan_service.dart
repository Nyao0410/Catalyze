import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_ai_assistant/models/study_plan.dart';
import 'package:study_ai_assistant/models/learning_record.dart';

class PlanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 'study_plans'コレクションへの参照
  CollectionReference<StudyPlan> get _studyPlansRef =>
      _firestore.collection('study_plans').withConverter<StudyPlan>(
            fromFirestore: (snapshot, _) => StudyPlan.fromMap(snapshot.data()!),
            toFirestore: (plan, _) => plan.toMap(),
          );

  // すべての学習計画をストリームとして取得
  Stream<List<StudyPlan>> getStudyPlans() {
    return _studyPlansRef.orderBy('creationDate', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // 学習計画の追加
  Future<void> addStudyPlan(StudyPlan plan) {
    return _studyPlansRef.doc(plan.id).set(plan);
  }

  // 学習計画の更新
  Future<void> updateStudyPlan(StudyPlan plan) {
    return _studyPlansRef.doc(plan.id).update(plan.toMap());
  }

  // 学習計画の削除
  Future<void> deleteStudyPlan(String planId) {
    return _studyPlansRef.doc(planId).delete();
  }

  // --- 学習記録（LearningRecord）用のメソッド ---

  // 指定された学習計画に紐づく'learning_records'サブコレクションへの参照
  CollectionReference<LearningRecord> _learningRecordsRef(String planId) =>
      _studyPlansRef.doc(planId).collection('learning_records').withConverter<LearningRecord>(
            fromFirestore: (snapshot, _) => LearningRecord.fromMap(snapshot.data()!),
            toFirestore: (record, _) => record.toMap(),
          );

  // 指定された学習計画のすべての学習記録をストリームとして取得
  Stream<List<LearningRecord>> getLearningRecords(String planId) {
    return _learningRecordsRef(planId).orderBy('recordDate', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // 新しい学習記録を追加
  Future<void> addLearningRecord(String planId, LearningRecord record) {
    return _learningRecordsRef(planId).doc(record.id).set(record);
  }
}
