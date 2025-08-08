import 'package:cloud_firestore/cloud_firestore.dart';

class LearningRecord {
  final String id;
  final DateTime recordDate;
  final int durationInSeconds;
  final int pagesCompleted;
  final int difficulty;
  final int concentration;
  final int actualPt; // 実績PT

  LearningRecord({
    required this.id,
    required this.recordDate,
    required this.durationInSeconds,
    required this.pagesCompleted,
    required this.difficulty,
    required this.concentration,
    required this.actualPt,
  });

  factory LearningRecord.fromMap(Map<String, dynamic> map) {
    return LearningRecord(
      id: map['id'] as String,
      recordDate: (map['recordDate'] as Timestamp).toDate(),
      durationInSeconds: map['durationInSeconds'] as int,
      pagesCompleted: map['pagesCompleted'] as int,
      difficulty: map['difficulty'] as int,
      concentration: map['concentration'] as int,
      actualPt: map['actualPt'] as int? ?? 0, // 互換性のためのnullチェック
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recordDate': Timestamp.fromDate(recordDate),
      'durationInSeconds': durationInSeconds,
      'pagesCompleted': pagesCompleted,
      'difficulty': difficulty,
      'concentration': concentration,
      'actualPt': actualPt,
    };
  }
}
