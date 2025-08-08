import 'package:cloud_firestore/cloud_firestore.dart';

class StudyPlan {
  final String id;
  final String title;
  final int totalAmount;
  final int completedAmount;
  final String unit;
  final Timestamp createdAt;
  // --- ここから追加 ---
  final Timestamp? deadline; // 目標達成日
  final int priority; // 優先度 (1:高, 2:中, 3:低)
  final bool isActive; // アーカイブフラグ
  final String description; // 説明
  final int predictedPt; // 予測PT
  // --- ここまで追加 ---

  StudyPlan({
    required this.id,
    required this.title,
    required this.totalAmount,
    this.completedAmount = 0,
    required this.unit,
    required this.createdAt,
    // --- ここから追加 ---
    this.deadline,
    this.priority = 2, // デフォルトは中優先度
    this.isActive = true, // デフォルトはアクティブ
    this.description = '', // デフォルトは空文字列
    this.predictedPt = 0, // デフォルトは0
    // --- ここまで追加 ---
  });

  factory StudyPlan.fromMap(Map<String, dynamic> map, String id) {
    return StudyPlan(
      id: id,
      title: map['title'] ?? '',
      totalAmount: map['totalAmount'] ?? 0,
      completedAmount: map['completedAmount'] ?? 0,
      unit: map['unit'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      // --- ここから追加 ---
      deadline: map['deadline'], // null許容
      priority: map['priority'] ?? 2,
      isActive: map['isActive'] ?? true,
      description: map['description'] ?? '',
      predictedPt: map['predictedPt'] ?? 0,
      // --- ここまで追加 ---
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'totalAmount': totalAmount,
      'completedAmount': completedAmount,
      'unit': unit,
      'createdAt': createdAt,
      // --- ここから追加 ---
      'deadline': deadline,
      'priority': priority,
      'isActive': isActive,
      'description': description,
      'predictedPt': predictedPt,
      // --- ここまで追加 ---
    };
  }

  StudyPlan copyWith({
    String? id,
    String? title,
    int? totalAmount,
    int? completedAmount,
    String? unit,
    Timestamp? createdAt,
    Timestamp? deadline,
    int? priority,
    bool? isActive,
    String? description,
    int? predictedPt,
  }) {
    return StudyPlan(
      id: id ?? this.id,
      title: title ?? this.title,
      totalAmount: totalAmount ?? this.totalAmount,
      completedAmount: completedAmount ?? this.completedAmount,
      unit: unit ?? this.unit,
      createdAt: createdAt ?? this.createdAt,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
      predictedPt: predictedPt ?? this.predictedPt,
    );
  }
}
