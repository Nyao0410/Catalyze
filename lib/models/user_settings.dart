class UserSettings {
  final String userId;
  final int dailyGoalInPT;
  final List<int> preferredStudyDays; // 0:月曜, 1:火曜...

  UserSettings({
    required this.userId,
    this.dailyGoalInPT = 4, // デフォルトは4PT
    this.preferredStudyDays = const [0, 1, 2, 3, 4], // デフォルトは平日
  });

   factory UserSettings.fromMap(Map<String, dynamic> map, String userId) {
    return UserSettings(
      userId: userId,
      dailyGoalInPT: map['dailyGoalInPT'] ?? 4,
      preferredStudyDays: List<int>.from(map['preferredStudyDays'] ?? [0, 1, 2, 3, 4]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dailyGoalInPT': dailyGoalInPT,
      'preferredStudyDays': preferredStudyDays,
    };
  }
}
