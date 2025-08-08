import 'package:hive/hive.dart';

part 'learning_record.g.dart';

@HiveType(typeId: 1)
class LearningRecord extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late DateTime recordDate;

  @HiveField(2)
  late int durationInSeconds;

  @HiveField(3)
  late int pagesCompleted;

  @HiveField(4)
  late int difficulty; // 1 to 5

  @HiveField(5)
  late int concentration; // 1 to 3

  LearningRecord({
    required this.id,
    required this.recordDate,
    required this.durationInSeconds,
    required this.pagesCompleted,
    required this.difficulty,
    required this.concentration,
  });
}