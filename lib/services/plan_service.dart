import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_ai_assistant/models/learning_record.dart';
import 'package:study_ai_assistant/models/study_plan.dart';
import 'package:study_ai_assistant/models/user_settings.dart'; // 追加

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

  CollectionReference<UserSettings> get _userSettingsRef => _firestore
      .collection('users')
      .doc(_currentUser!.uid)
      .collection('settings')
      .withConverter<UserSettings>(
        fromFirestore: (snapshot, _) => UserSettings.fromMap(snapshot.data()!, snapshot.id),
        toFirestore: (settings, _) => settings.toMap(),
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
  Future<Map<String, double>> getOverallProgress() async {
    if (_currentUser == null) return {'totalDailyQuotaAmount': 0.0, 'totalCompletedAmountToday': 0.0};

    final plansSnapshot = await _plansRef.where('isActive', isEqualTo: true).get();
    if (plansSnapshot.docs.isEmpty) return {'totalDailyQuotaAmount': 0.0, 'totalCompletedAmountToday': 0.0};

    double totalDailyQuotaAmount = 0.0;
    for (var doc in plansSnapshot.docs) {
      final plan = doc.data();
      // 各プランの学習記録を取得
      final recordsSnapshot = await _recordsRef.where('planId', isEqualTo: plan.id).get();
      final records = recordsSnapshot.docs.map((e) => e.data()).toList();

      final dailyQuotaInfo = calculateDailyQuotaInfo(plan, records);
      // dailyQuotaTextから数値部分を抽出して合計
      if (dailyQuotaInfo.dailyQuotaText.startsWith('1日あたり約')) {
        final quotaString = dailyQuotaInfo.dailyQuotaText.replaceAll('1日あたり約', '').replaceAll(plan.unit, '');
        totalDailyQuotaAmount += double.tryParse(quotaString) ?? 0.0;
      }
    }

    // 今日の学習記録の合計amountを取得
    final now = DateTime.now();
    final startOfDay = Timestamp.fromDate(DateTime(now.year, now.month, now.day));
    final endOfDay = Timestamp.fromDate(DateTime(now.year, now.month, now.day, 23, 59, 59));

    final todayRecordsSnapshot = await _recordsRef
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .get();

    double totalCompletedAmountToday = todayRecordsSnapshot.docs.fold<double>(0.0, (currentSum, doc) => currentSum + doc.data().amount);

    return {
      'totalDailyQuotaAmount': totalDailyQuotaAmount,
      'totalCompletedAmountToday': totalCompletedAmountToday,
    };
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

  /// すべての学習記録を取得する
  Future<List<LearningRecord>> getAllLearningRecords() async {
    if (_currentUser == null) return [];
    final querySnapshot = await _recordsRef
        .orderBy('date', descending: true)
        .get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  /// 今日の学習目標PT数を取得する
  Future<int> getTodayLearningGoal() async {
    if (_currentUser == null) return 0;
    final doc = await _userSettingsRef.doc(_currentUser!.uid).get();
    return doc.data()?.dailyGoalInPT ?? 4; // デフォルトは4PT
  }

  /// 今日の学習記録から完了したPT数を合計する
  Future<int> getTodayCompletedPt() async {
    if (_currentUser == null) return 0;
    final now = DateTime.now();
    final startOfDay = Timestamp.fromDate(DateTime(now.year, now.month, now.day));
    final endOfDay = Timestamp.fromDate(DateTime(now.year, now.month, now.day, 23, 59, 59));

    final querySnapshot = await _recordsRef
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .get();

    return querySnapshot.docs.fold<int>(0, (currentSum, doc) => currentSum + doc.data().ptCount);
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
