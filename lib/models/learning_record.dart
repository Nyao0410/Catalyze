import 'package:cloud_firestore/cloud_firestore.dart';

class LearningRecord {
  final String id;
  final String planId;
  final int amount;
  final int durationInMinutes;
  final Timestamp date;
  final int concentration;
  final int difficulty;
  // --- ここから追加 ---
  final int ptCount; // PT数
  // --- ここまで追加 ---

  LearningRecord({
    required this.id,
    required this.planId,
    required this.amount,
    required this.durationInMinutes,
    required this.date,
    required this.concentration,
    required this.difficulty,
    // --- ここから追加 ---
    required this.ptCount,
    // --- ここまで追加 ---
  });

  factory LearningRecord.fromMap(Map<String, dynamic> map, String id) {
    return LearningRecord(
      id: id,
      planId: map['planId'] ?? '',
      amount: map['amount'] ?? 0,
      durationInMinutes: map['durationInMinutes'] ?? 0,
      date: map['date'] ?? Timestamp.now(),
      concentration: map['concentration'] ?? 3,
      difficulty: map['difficulty'] ?? 3,
      // --- ここから追加 ---
      ptCount: map['ptCount'] ?? 0,
      // --- ここまで追加 ---
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'planId': planId,
      'amount': amount,
      'durationInMinutes': durationInMinutes,
      'date': date,
      'concentration': concentration,
      'difficulty': difficulty,
      // --- ここから追加 ---
      'ptCount': ptCount,
      // --- ここまで追加 ---
    };
  }
}