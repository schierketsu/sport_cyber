import 'dart:convert';

/// Настройки мини-планировщика: учёба/работа, сон, макс. время игры в день.
class PlannerSettings {
  PlannerSettings({
    this.workHoursPerDay,
    this.sleepGoalHours = 7.0,
    this.maxPlayHoursPerDay = 3.0,
  });

  final double? workHoursPerDay; // null = свободный день
  final double sleepGoalHours;
  final double maxPlayHoursPerDay;

  Map<String, dynamic> toJson() => {
        'workHoursPerDay': workHoursPerDay,
        'sleepGoalHours': sleepGoalHours,
        'maxPlayHoursPerDay': maxPlayHoursPerDay,
      };

  static PlannerSettings fromJson(Map<String, dynamic> json) =>
      PlannerSettings(
        workHoursPerDay: (json['workHoursPerDay'] as num?)?.toDouble(),
        sleepGoalHours:
            (json['sleepGoalHours'] as num?)?.toDouble() ?? 7.0,
        maxPlayHoursPerDay:
            (json['maxPlayHoursPerDay'] as num?)?.toDouble() ?? 3.0,
      );

  static PlannerSettings? fromJsonString(String? jsonStr) {
    if (jsonStr == null) return null;
    try {
      return fromJson(
        Map<String, dynamic>.from(jsonDecode(jsonStr) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  String toJsonString() => jsonEncode(toJson());

  PlannerSettings copyWith({
    double? workHoursPerDay,
    double? sleepGoalHours,
    double? maxPlayHoursPerDay,
  }) =>
      PlannerSettings(
        workHoursPerDay: workHoursPerDay ?? this.workHoursPerDay,
        sleepGoalHours: sleepGoalHours ?? this.sleepGoalHours,
        maxPlayHoursPerDay:
            maxPlayHoursPerDay ?? this.maxPlayHoursPerDay,
      );
}
