import 'package:flutter/foundation.dart';
import '../core/models.dart';
import '../core/storage.dart';
import '../core/constants.dart';
import '../features/planner/planner_settings.dart';
import '../features/burnout/burnout_indicator.dart';

class AppState extends ChangeNotifier {
  AppState(this._storage) {
    _load();
  }

  final AppStorage _storage;

  List<DayRecord> _days = [];
  PlannerSettings? _plannerSettings;
  DateTime? _sessionStart;
  bool _tiltDialogActive = false;
  bool _antiTiltScreenShowing = false;
  bool get antiTiltScreenShowing => _antiTiltScreenShowing;
  bool _wellnessReminderVisible = false;
  String _wellnessReminderType = 'neck'; // neck, wrists, back, eyes
  Mood? _lastMood;

  List<DayRecord> get days => List.unmodifiable(_days);
  PlannerSettings? get plannerSettings => _plannerSettings;
  bool get isSessionActive => _sessionStart != null;
  DateTime? get sessionStart => _sessionStart;
  bool get tiltDialogActive => _tiltDialogActive;
  bool get wellnessReminderVisible => _wellnessReminderVisible;
  String get wellnessReminderType => _wellnessReminderType;
  bool get wellnessReminderEnabled => _storage.getWellnessReminderEnabled();
  int get wellnessReminderMinutes => _storage.getWellnessReminderMinutes();

  static const _wellnessTypes = ['neck', 'wrists', 'back', 'eyes'];

  void requestWellnessReminder() {
    final index = DateTime.now().millisecond % _wellnessTypes.length;
    _wellnessReminderType = _wellnessTypes[index];
    _wellnessReminderVisible = true;
    notifyListeners();
  }

  void dismissWellnessReminder() {
    _wellnessReminderVisible = false;
    notifyListeners();
  }

  String get _todayKey {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  DayRecord get todayRecord {
    try {
      final existing = _days.firstWhere((e) => e.date == _todayKey);
      return existing;
    } catch (_) {}
    final newRecord = DayRecord(date: _todayKey);
    _days.add(newRecord);
    _days.sort((a, b) => b.date.compareTo(a.date));
    _saveDays();
    return newRecord;
  }

  void _load() {
    _plannerSettings =
        PlannerSettings.fromJsonString(_storage.getPlannerSettingsJson());
    _days = _storage
        .getDays()
        .map((e) => DayRecord.fromJson(e))
        .toList();
    _days.sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> _saveDays() async {
    await _storage.setDays(_days.map((e) => e.toJson()).toList());
    notifyListeners();
  }

  Future<void> setPlannerSettings(PlannerSettings s) async {
    _plannerSettings = s;
    await _storage.setPlannerSettingsJson(s.toJsonString());
    notifyListeners();
  }

  Future<void> setWellnessReminderEnabled(bool v) async {
    await _storage.setWellnessReminderEnabled(v);
    notifyListeners();
  }

  Future<void> setWellnessReminderMinutes(int v) async {
    await _storage.setWellnessReminderMinutes(v);
    notifyListeners();
  }

  void startSession() {
    _sessionStart = DateTime.now();
    notifyListeners();
  }

  void endSession({
    double? manualHours,
    Mood? mood,
    int? losingStreak,
    bool? myPlaySatisfied,
    bool? teamPlaySatisfied,
  }) {
    final today = todayRecord;
    double hours = manualHours ?? 0;
    DateTime? sessionStart = _sessionStart;
    _sessionStart = null;

    if (sessionStart != null && manualHours == null) {
      hours = DateTime.now().difference(sessionStart).inMinutes / 60.0;
    }

    final resolvedMood = mood ?? (myPlaySatisfied == false ? Mood.bad : myPlaySatisfied == true ? Mood.good : today.mood);
    List<SessionRecord> newSessions = List.from(today.sessions);

    if (sessionStart != null && hours > 0) {
      final startOfDay = DateTime(sessionStart.year, sessionStart.month, sessionStart.day);
      final startMinutes = sessionStart.difference(startOfDay).inMinutes;
      final durationMinutes = (hours * 60).round().clamp(1, 24 * 60);
      newSessions.add(SessionRecord(
        startMinutes: startMinutes,
        durationMinutes: durationMinutes,
        myPlaySatisfied: myPlaySatisfied ?? today.myPlaySatisfied,
        teamPlaySatisfied: teamPlaySatisfied ?? today.teamPlaySatisfied,
        mood: resolvedMood,
      ));
    }

    final updated = today.copyWith(
      playHours: today.playHours + hours,
      mood: resolvedMood,
      losingStreak: losingStreak ?? today.losingStreak,
      myPlaySatisfied: myPlaySatisfied ?? today.myPlaySatisfied,
      teamPlaySatisfied: teamPlaySatisfied ?? today.teamPlaySatisfied,
      sessions: newSessions,
    );
    _updateDay(updated);
    if (resolvedMood != null) _lastMood = resolvedMood;
    final streak = losingStreak ?? today.losingStreak;
    if (resolvedMood == Mood.bad && streak >= losingStreakTiltThreshold) {
      _tiltDialogActive = true;
    }
    notifyListeners();
  }

  void addPlayHours(double hours) {
    final today = todayRecord;
    _updateDay(today.copyWith(playHours: today.playHours + hours));
  }

  void setTodaySleep(double hours) {
    final today = todayRecord;
    _updateDay(today.copyWith(sleepHours: hours));
    notifyListeners();
  }

  void setTodayBreaks(int count) {
    final today = todayRecord;
    _updateDay(today.copyWith(breaksCount: count));
    notifyListeners();
  }

  void setTodayMood(Mood mood) {
    final today = todayRecord;
    _updateDay(today.copyWith(mood: mood));
    _lastMood = mood;
    if (mood == Mood.bad && today.losingStreak >= losingStreakTiltThreshold) {
      _tiltDialogActive = true;
    }
    notifyListeners();
  }

  void setTodayLosingStreak(int streak) {
    final today = todayRecord;
    _updateDay(today.copyWith(losingStreak: streak));
    notifyListeners();
  }

  void _updateDay(DayRecord record) {
    final i = _days.indexWhere((e) => e.date == record.date);
    if (i >= 0) {
      _days[i] = record;
    } else {
      _days.add(record);
      _days.sort((a, b) => b.date.compareTo(a.date));
    }
    _saveDays();
  }

  double get playHoursThisWeek {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return _days
        .where((d) {
          final parts = d.date.split('-');
          if (parts.length != 3) return false;
          final dt = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
          return !dt.isBefore(weekAgo) && !dt.isAfter(now);
        })
        .fold<double>(0, (s, d) => s + d.playHours);
  }

  BurnoutResult getBurnoutResult() =>
      BurnoutIndicator.evaluate(
        today: todayRecord,
        days: _days,
        playHoursThisWeek: playHoursThisWeek,
        maxPlayPerDay: _plannerSettings?.maxPlayHoursPerDay ?? maxPlayHoursPerDay,
      );

  bool shouldTriggerTilt() {
    final r = todayRecord;
    if (r.losingStreak >= losingStreakTiltThreshold) return true;
    if (_lastMood == Mood.bad && r.mood == Mood.bad) return true;
    return false;
  }

  void showTiltDialog() {
    _tiltDialogActive = true;
    notifyListeners();
  }

  void dismissTiltDialog() {
    _tiltDialogActive = false;
    notifyListeners();
  }

  void markAntiTiltScreenShowing() {
    _antiTiltScreenShowing = true;
    notifyListeners();
  }

  void clearAntiTiltScreenShowing() {
    _antiTiltScreenShowing = false;
    notifyListeners();
  }

  void triggerTiltFromUi() {
    showTiltDialog();
  }
}
