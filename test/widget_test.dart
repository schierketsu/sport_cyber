import 'package:flutter_test/flutter_test.dart';
import 'package:cyber_trainer/core/models.dart';
import 'package:cyber_trainer/features/burnout/burnout_indicator.dart';

void main() {
  test('Burnout indicator returns green for light load', () {
    final today = DayRecord(
      date: '2025-02-07',
      playHours: 1,
      sleepHours: 7,
      breaksCount: 2,
      mood: Mood.good,
      losingStreak: 0,
    );
    final result = BurnoutIndicator.evaluate(
      today: today,
      days: [today],
      playHoursThisWeek: 10,
    );
    expect(result.level, BurnoutLevel.green);
    expect(result.reason, isNotEmpty);
    expect(result.recommendation, isNotEmpty);
  });
  test('Burnout red when sleep low and mood bad', () {
    final today = DayRecord(
      date: '2025-02-07',
      playHours: 5,
      sleepHours: 4,
      breaksCount: 0,
      mood: Mood.bad,
      losingStreak: 4,
    );
    final days = [
      DayRecord(date: '2025-02-05', playHours: 3),
      DayRecord(date: '2025-02-06', playHours: 3),
      today,
    ];
    final result = BurnoutIndicator.evaluate(
      today: today,
      days: days,
      playHoursThisWeek: 30,
    );
    expect(result.level, BurnoutLevel.red);
  });
}
