import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const _keyPlannerSettings = 'planner_settings';
const _keyDays = 'days';
const _keyWellnessReminderEnabled = 'wellness_reminder_enabled';
const _keyWellnessReminderMinutes = 'wellness_reminder_minutes';

class AppStorage {
  AppStorage(this._prefs);

  final SharedPreferences _prefs;

  static Future<AppStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AppStorage(prefs);
  }

  String? getPlannerSettingsJson() => _prefs.getString(_keyPlannerSettings);
  Future<void> setPlannerSettingsJson(String json) =>
      _prefs.setString(_keyPlannerSettings, json);

  List<Map<String, dynamic>> getDays() {
    final raw = _prefs.getString(_keyDays);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> setDays(List<Map<String, dynamic>> days) async {
    await _prefs.setString(_keyDays, jsonEncode(days));
  }

  bool getWellnessReminderEnabled() =>
      _prefs.getBool(_keyWellnessReminderEnabled) ?? true;

  Future<void> setWellnessReminderEnabled(bool value) =>
      _prefs.setBool(_keyWellnessReminderEnabled, value);

  int getWellnessReminderMinutes() =>
      _prefs.getInt(_keyWellnessReminderMinutes) ?? 20;

  Future<void> setWellnessReminderMinutes(int value) =>
      _prefs.setInt(_keyWellnessReminderMinutes, value);
}
