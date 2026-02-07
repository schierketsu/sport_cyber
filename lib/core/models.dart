// Модель одного дня: игровое время, сон, перерывы, настроение, серия поражений, оценка своей/команды.
// Сессии (катки) хранятся отдельно для графика по минутам.

enum Mood { bad, ok, good }

/// Одна игровая сессия (катка): начало, длительность, качество (по оценкам).
class SessionRecord {
  SessionRecord({
    required this.startMinutes,
    required this.durationMinutes,
    this.myPlaySatisfied,
    this.teamPlaySatisfied,
    this.mood,
  });

  /// Минуты от начала дня (0 = 00:00).
  final int startMinutes;
  final int durationMinutes;
  final bool? myPlaySatisfied;
  final bool? teamPlaySatisfied;
  final Mood? mood;

  int get endMinutes => startMinutes + durationMinutes;

  Map<String, dynamic> toJson() => {
        'startMinutes': startMinutes,
        'durationMinutes': durationMinutes,
        'myPlaySatisfied': myPlaySatisfied,
        'teamPlaySatisfied': teamPlaySatisfied,
        'mood': mood?.name,
      };

  static SessionRecord fromJson(Map<String, dynamic> json) => SessionRecord(
        startMinutes: json['startMinutes'] as int? ?? 0,
        durationMinutes: json['durationMinutes'] as int? ?? 0,
        myPlaySatisfied: json['myPlaySatisfied'] as bool?,
        teamPlaySatisfied: json['teamPlaySatisfied'] as bool?,
        mood: json['mood'] != null
            ? Mood.values.byName(json['mood'] as String)
            : null,
      );
}

class DayRecord {
  DayRecord({
    required this.date,
    this.playHours = 0,
    this.sleepHours,
    this.breaksCount = 0,
    this.mood,
    this.losingStreak = 0,
    this.myPlaySatisfied,
    this.teamPlaySatisfied,
    this.sessions = const [],
  });

  final String date; // yyyy-MM-dd
  final double playHours;
  final double? sleepHours;
  final int breaksCount;
  final Mood? mood;
  final int losingStreak;
  /// true = thumb up, false = thumb down (последняя катка)
  final bool? myPlaySatisfied;
  final bool? teamPlaySatisfied;
  final List<SessionRecord> sessions;

  Map<String, dynamic> toJson() => {
        'date': date,
        'playHours': playHours,
        'sleepHours': sleepHours,
        'breaksCount': breaksCount,
        'mood': mood?.name,
        'losingStreak': losingStreak,
        'myPlaySatisfied': myPlaySatisfied,
        'teamPlaySatisfied': teamPlaySatisfied,
        'sessions': sessions.map((e) => e.toJson()).toList(),
      };

  static DayRecord fromJson(Map<String, dynamic> json) {
    final sessionsList = json['sessions'] as List<dynamic>?;
    return DayRecord(
      date: json['date'] as String,
      playHours: (json['playHours'] as num?)?.toDouble() ?? 0,
      sleepHours: (json['sleepHours'] as num?)?.toDouble(),
      breaksCount: json['breaksCount'] as int? ?? 0,
      mood: json['mood'] != null
          ? Mood.values.byName(json['mood'] as String)
          : null,
      losingStreak: json['losingStreak'] as int? ?? 0,
      myPlaySatisfied: json['myPlaySatisfied'] as bool?,
      teamPlaySatisfied: json['teamPlaySatisfied'] as bool?,
      sessions: sessionsList != null
          ? sessionsList
              .map((e) => SessionRecord.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList()
          : [],
    );
  }

  DayRecord copyWith({
    String? date,
    double? playHours,
    double? sleepHours,
    int? breaksCount,
    Mood? mood,
    int? losingStreak,
    bool? myPlaySatisfied,
    bool? teamPlaySatisfied,
    List<SessionRecord>? sessions,
  }) =>
      DayRecord(
        date: date ?? this.date,
        playHours: playHours ?? this.playHours,
        sleepHours: sleepHours ?? this.sleepHours,
        breaksCount: breaksCount ?? this.breaksCount,
        mood: mood ?? this.mood,
        losingStreak: losingStreak ?? this.losingStreak,
        myPlaySatisfied: myPlaySatisfied ?? this.myPlaySatisfied,
        teamPlaySatisfied: teamPlaySatisfied ?? this.teamPlaySatisfied,
        sessions: sessions ?? this.sessions,
      );
}
