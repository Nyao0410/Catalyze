import 'package:hive/hive.dart';
import 'package:study_ai_assistant/models/learning_record.dart';

part 'study_plan.g.dart';

@HiveType(typeId: 0)
class StudyPlan extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late int totalPages;

  @HiveField(3)
  late DateTime targetDate;
  
  @HiveField(4)
  late DateTime creationDate;

  @HiveField(5)
  late HiveList<LearningRecord> records;

  @HiveField(6)
  late String unit;

  @HiveField(7) // New
  String? description;

  @HiveField(8) // New
  List<String>? tags;

  @HiveField(9) // New
  int? initialDifficulty;

  StudyPlan({
    required this.id,
    required this.title,
    required this.totalPages,
    required this.targetDate,
    required this.creationDate,
    required this.records,
    required this.unit,
    this.description,
    this.tags,
    this.initialDifficulty,
  });

  int get completedPages => records.fold(0, (sum, record) => sum + record.pagesCompleted);
  int get remainingPages => totalPages - completedPages;
  int get remainingDays {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final difference = targetDay.difference(today).inDays + 1;
    return difference > 0 ? difference : 1;
  }
  int get dailyTarget {
    if (remainingPages <= 0) return 0;
    return (remainingPages / remainingDays).ceil();
  }
  int get pagesCompletedToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return records
        .where((r) =>
            r.recordDate.year == today.year &&
            r.recordDate.month == today.month &&
            r.recordDate.day == today.day)
        .fold(0, (sum, record) => sum + record.pagesCompleted);
  }
}