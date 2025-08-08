import 'package:cloud_firestore/cloud_firestore.dart';

class StudyPlan {
  final String id;
  final String title;
  final int totalPages;
  final DateTime targetDate;
  final DateTime creationDate;
  final String unit;
  final String description;
  final List<String> tags;
  final int initialDifficulty;
  final int predictedPt; // 予測PT

  StudyPlan({
    required this.id,
    required this.title,
    required this.totalPages,
    required this.targetDate,
    required this.creationDate,
    required this.unit,
    required this.description,
    required this.tags,
    required this.initialDifficulty,
    required this.predictedPt,
  });

  factory StudyPlan.fromMap(Map<String, dynamic> map) {
    return StudyPlan(
      id: map['id'] as String,
      title: map['title'] as String,
      totalPages: map['totalPages'] as int,
      targetDate: (map['targetDate'] as Timestamp).toDate(),
      creationDate: (map['creationDate'] as Timestamp).toDate(),
      unit: map['unit'] as String,
      description: map['description'] as String,
      tags: List<String>.from(map['tags'] as List<dynamic>),
      initialDifficulty: map['initialDifficulty'] as int,
      predictedPt: map['predictedPt'] as int? ?? 0, // 互換性のためのnullチェック
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'totalPages': totalPages,
      'targetDate': Timestamp.fromDate(targetDate),
      'creationDate': Timestamp.fromDate(creationDate),
      'unit': unit,
      'description': description,
      'tags': tags,
      'initialDifficulty': initialDifficulty,
      'predictedPt': predictedPt,
    };
  }
}
