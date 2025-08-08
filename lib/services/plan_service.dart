import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_ai_assistant/models/learning_record.dart';
import 'package:study_ai_assistant/models/study_plan.dart';

class PlanService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  User? get _currentUser => _auth.currentUser;

  CollectionReference<StudyPlan> get _plansRef => _firestore
      .collection('users')
      .doc(_currentUser!.uid)
      .collection('plans')
      .withConverter<StudyPlan>(
        fromFirestore: (snapshot, _) => StudyPlan.fromMap(snapshot.data()!, snapshot.id),
        toFirestore: (plan, _) => plan.toMap(),
      );
  
  CollectionReference<LearningRecord> get _recordsRef => _firestore
      .collection('users')
      .doc(_currentUser!.uid)
      .collection('learning_records')
      .withConverter<LearningRecord>(
        fromFirestore: (snapshot, _) => LearningRecord.fromMap(snapshot.data()!, snapshot.id),
        toFirestore: (record, _) => record.toMap(),
      );

  Stream<List<StudyPlan>> getPlans() {
    if (_currentUser == null) return Stream.value([]);
    return _plansRef
        .where('isActive', isEqualTo: true)
        .orderBy('priority')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> addPlan(StudyPlan plan) async {
    if (_currentUser == null) return;
    await _plansRef.add(plan);
  }

  /// 新しい学習記録を追加する
  Future<void> addLearningRecord(LearningRecord record) async {
    if (_currentUser == null) return;
    await _recordsRef.add(record);
  }

  /// 全体の進捗度を計算して返す (0.0 ~ 1.0)
  Future<double> getOverallProgress() async {
    if (_currentUser == null) return 0.0;
    
    final querySnapshot = await _plansRef.where('isActive', isEqualTo: true).get();
    if (querySnapshot.docs.isEmpty) return 0.0;

    int totalAmountSum = 0;
    int completedAmountSum = 0;

    for (var doc in querySnapshot.docs) {
      final plan = doc.data();
      totalAmountSum += plan.totalAmount;
      completedAmountSum += plan.completedAmount;
    }
    
    if (totalAmountSum == 0) return 0.0;

    return completedAmountSum / totalAmountSum;
  }

  /// 週間学習データを取得する
  Future<List<LearningRecord>> getWeeklyLearningRecords() async {
     if (_currentUser == null) return [];

    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));
    
    final querySnapshot = await _recordsRef
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(oneWeekAgo))
        .orderBy('date', descending: true)
        .get();
        
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }
  
  /// 参考書ごとの学習バランスデータを取得する
  Future<Map<String, Duration>> getBookBalanceData() async {
    if (_currentUser == null) return {};

    final recordsSnapshot = await _recordsRef.get();
    if (recordsSnapshot.docs.isEmpty) return {};

    final planIdToTitle = <String, String>{};
    final plansSnapshot = await _plansRef.get();
    for (var doc in plansSnapshot.docs) {
      planIdToTitle[doc.id] = doc.data().title;
    }

    final balance = <String, int>{}; // title, totalMinutes
    for (var doc in recordsSnapshot.docs) {
      final record = doc.data();
      final title = planIdToTitle[record.planId] ?? '不明な計画';
      balance.update(
        title,
        (value) => value + record.durationInMinutes,
        ifAbsent: () => record.durationInMinutes,
      );
    }
    
    return balance.map((key, value) => MapEntry(key, Duration(minutes: value)));
  }

  Future<void> updatePlan(StudyPlan plan) async {
    if (_currentUser == null) return;
    try {
      await _plansRef.doc(plan.id).update(plan.toMap());
    } catch (e) {
      // TODO: より適切なエラーハンドリングを実装する
      // print('Error updating plan: $e');
      rethrow;
    }
  }

  Future<void> deletePlan(String planId) async {
    if (_currentUser == null) return;
    await _plansRef.doc(planId).delete();
  }

  Stream<List<LearningRecord>> getLearningRecords(String planId) {
    if (_currentUser == null) return Stream.value([]);
    return _recordsRef
        .where('planId', isEqualTo: planId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}

class DailyQuotaInfo {
  final double pagesCompleted;
  final double progress;
  final double remainingPages;
  final String dailyQuotaText;

  DailyQuotaInfo({
    required this.pagesCompleted,
    required this.progress,
    required this.remainingPages,
    required this.dailyQuotaText,
  });
}

DailyQuotaInfo calculateDailyQuotaInfo(StudyPlan plan, List<LearningRecord> records) {
  final double pagesCompleted = records.fold<double>(0.0, (currentSum, record) => currentSum + record.amount);
  final progress = plan.totalAmount > 0 ? pagesCompleted / plan.totalAmount : 0.0;
  final double remainingPages = plan.totalAmount - pagesCompleted;

  final now = DateTime.now();
  final totalDuration = plan.deadline?.toDate().difference(plan.createdAt.toDate()).inDays ?? 0;
  final bufferDays = (totalDuration * 0.2).floor();
  final effectiveTargetDate = plan.deadline?.toDate().subtract(Duration(days: bufferDays)) ?? now;
  final remainingDays = effectiveTargetDate.difference(now).inDays;

  String dailyQuotaText;
  if (remainingPages <= 0) {
    dailyQuotaText = '完了！';
  } else if (remainingDays <= 0) {
    dailyQuotaText = '本日中に${remainingPages.toStringAsFixed(1)}${plan.unit}';
  } else {
    final dailyQuota = remainingPages / remainingDays;
    dailyQuotaText = '1日あたり約${dailyQuota.toStringAsFixed(1)}${plan.unit}';
  }

  return DailyQuotaInfo(
    pagesCompleted: pagesCompleted,
    progress: progress,
    remainingPages: remainingPages,
    dailyQuotaText: dailyQuotaText,
  );
}
