import 'package:json_annotation/json_annotation.dart';

part 'algorithm_config.g.dart';

/// Configuration for various algorithms used in the application.
///
/// This class allows for easy serialization and deserialization of
/// algorithm parameters, enabling dynamic adjustments without code changes.
@JsonSerializable()
class AlgorithmConfig {
  /// Thresholds for achievement rate to adjust daily quota.
  /// Example: {'high': 1.2, 'low': 0.8}
  final Map<String, double> achievementThresholds;

  /// Efficiency factor for dynamic deadline adjustments based on pace.
  /// Example: 0.25 (25% of the difference is reduced)
  final double roundEfficiency;

  /// Base intervals for spaced repetition review schedules in days.
  /// Example: [1, 7, 30, 90]
  final List<int> reviewIntervals;

  /// Creates an [AlgorithmConfig] instance.
  AlgorithmConfig({
    required this.achievementThresholds,
    required this.roundEfficiency,
    required this.reviewIntervals,
  });

  /// Creates an [AlgorithmConfig] from a JSON map.
  factory AlgorithmConfig.fromJson(Map<String, dynamic> json) =>
      _$AlgorithmConfigFromJson(json);

  /// Converts this [AlgorithmConfig] to a JSON map.
  Map<String, dynamic> toJson() => _$AlgorithmConfigToJson(this);
}
