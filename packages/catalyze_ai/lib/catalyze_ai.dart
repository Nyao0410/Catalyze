/// A Dart package for AI-powered study planning and analysis.
library catalyze_ai;

export 'package:catalyze_ai/models/user.dart';
export 'package:catalyze_ai/models/study_plan.dart';
export 'package:catalyze_ai/models/study_record.dart';
export 'package:catalyze_ai/models/review_schedule.dart';
export 'package:catalyze_ai/models/metrics.dart';

export 'package:catalyze_ai/algorithms/dynamic_quota.dart';
export 'package:catalyze_ai/algorithms/planning_algorithms.dart';

export 'package:catalyze_ai/services/repository.dart';
export 'package:catalyze_ai/services/in_memory_repository.dart';
export 'package:catalyze_ai/services/clock_provider.dart';
export 'package:catalyze_ai/services/firestore_repository_stub.dart';
