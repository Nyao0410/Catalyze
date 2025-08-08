import 'package:hive_flutter/hive_flutter.dart';
import 'package:study_ai_assistant/models/learning_record.dart';
import 'package:study_ai_assistant/models/study_plan.dart';

class PlanService {
  static const String _planBoxName = 'studyPlans';
  static const String _recordBoxName = 'learningRecords';

  static Future<void> init() async {
    Hive.registerAdapter(StudyPlanAdapter());
    Hive.registerAdapter(LearningRecordAdapter());
    await Hive.openBox<StudyPlan>(_planBoxName);
    await Hive.openBox<LearningRecord>(_recordBoxName);
  }

  static Box<StudyPlan> getPlansBox() => Hive.box<StudyPlan>(_planBoxName);
  static Box<LearningRecord> getRecordsBox() => Hive.box<LearningRecord>(_recordBoxName);

  static Future<void> addPlan(StudyPlan plan) async {
    final box = getPlansBox();
    await box.put(plan.id, plan);
  }
  
  static Future<void> updatePlan(StudyPlan plan) async {
    await plan.save();
  }

  static Future<void> deletePlan(StudyPlan plan) async {
    // First, delete associated records to avoid orphaned data
    for (var record in plan.records) {
      await record.delete();
    }
    // Then, delete the plan itself
    await plan.delete();
  }

  static Future<void> addLearningRecord(StudyPlan plan, LearningRecord record) async {
    final recordBox = getRecordsBox();
    await recordBox.put(record.id, record);
    plan.records.add(record);
    await plan.save();
  }
}