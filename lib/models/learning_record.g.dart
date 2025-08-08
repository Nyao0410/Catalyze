// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LearningRecordAdapter extends TypeAdapter<LearningRecord> {
  @override
  final int typeId = 1;

  @override
  LearningRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LearningRecord(
      id: fields[0] as String,
      recordDate: fields[1] as DateTime,
      durationInSeconds: fields[2] as int,
      pagesCompleted: fields[3] as int,
      difficulty: fields[4] as int,
      concentration: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LearningRecord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.recordDate)
      ..writeByte(2)
      ..write(obj.durationInSeconds)
      ..writeByte(3)
      ..write(obj.pagesCompleted)
      ..writeByte(4)
      ..write(obj.difficulty)
      ..writeByte(5)
      ..write(obj.concentration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearningRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
