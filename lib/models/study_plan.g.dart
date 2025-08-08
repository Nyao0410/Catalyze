// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_plan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StudyPlanAdapter extends TypeAdapter<StudyPlan> {
  @override
  final int typeId = 0;

  @override
  StudyPlan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StudyPlan(
      id: fields[0] as String,
      title: fields[1] as String,
      totalPages: fields[2] as int,
      targetDate: fields[3] as DateTime,
      creationDate: fields[4] as DateTime,
      records: (fields[5] as HiveList).castHiveList(),
      unit: fields[6] as String,
      description: fields[7] as String?,
      tags: (fields[8] as List?)?.cast<String>(),
      initialDifficulty: fields[9] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, StudyPlan obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.totalPages)
      ..writeByte(3)
      ..write(obj.targetDate)
      ..writeByte(4)
      ..write(obj.creationDate)
      ..writeByte(5)
      ..write(obj.records)
      ..writeByte(6)
      ..write(obj.unit)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.tags)
      ..writeByte(9)
      ..write(obj.initialDifficulty);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudyPlanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
