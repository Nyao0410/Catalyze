import 'package:cloud_firestore/cloud_firestore.dart';

class LearningRecord {
  final String id;
  final String planId;
  final double amount;
  final String unit;
  final int durationInMinutes;
  final Timestamp date;
  final int ptCount;
  final int concentrationLevel;
  final int difficulty;

  LearningRecord({
    required this.id,
    required this.planId,
    required this.amount,
    required this.unit,
    required this.durationInMinutes,
    required this.date,
    required this.ptCount,
    required this.concentrationLevel,
    required this.difficulty,
  });

  factory LearningRecord.fromMap(Map<String, dynamic> map, String id) {
    return LearningRecord(
      id: id,
      planId: map['planId'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit'] ?? '',
      durationInMinutes: map['durationInMinutes'] ?? 0,
      date: map['date'] ?? Timestamp.now(),
      ptCount: map['ptCount'] ?? 0,
      concentrationLevel: map['concentrationLevel'] ?? 3,
      difficulty: map['difficulty'] ?? 3,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'planId': planId,
      'amount': amount,
      'unit': unit,
      'durationInMinutes': durationInMinutes,
      'date': date,
      'ptCount': ptCount,
      'concentrationLevel': concentrationLevel,
      'difficulty': difficulty,
    };
  }
}