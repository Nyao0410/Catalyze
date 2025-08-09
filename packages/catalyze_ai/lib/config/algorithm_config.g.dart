// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'algorithm_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlgorithmConfig _$AlgorithmConfigFromJson(Map<String, dynamic> json) =>
    AlgorithmConfig(
      achievementThresholds:
          (json['achievementThresholds'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      roundEfficiency: (json['roundEfficiency'] as num).toDouble(),
      reviewIntervals: (json['reviewIntervals'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$AlgorithmConfigToJson(AlgorithmConfig instance) =>
    <String, dynamic>{
      'achievementThresholds': instance.achievementThresholds,
      'roundEfficiency': instance.roundEfficiency,
      'reviewIntervals': instance.reviewIntervals,
    };
