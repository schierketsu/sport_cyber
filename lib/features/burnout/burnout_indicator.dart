import '../../core/models.dart';
import '../../core/constants.dart';

enum BurnoutLevel { green, yellow, red }

class BurnoutResult {
  BurnoutResult({
    required this.level,
    required this.reason,
    required this.recommendation,
  });

  final BurnoutLevel level;
  final String reason;
  final String recommendation;
}

class BurnoutIndicator {
  static BurnoutResult evaluate({
    required DayRecord today,
    required List<DayRecord> days,
    required double playHoursThisWeek,
    double? maxPlayPerDay,
  }) {
    final maxDay = maxPlayPerDay ?? maxPlayHoursPerDay;
    final reasons = <String>[];
    int score = 0;

    // Игра сегодня
    if (today.playHours > maxDay) {
      reasons.add('превышен лимит игры сегодня (${today.playHours.toStringAsFixed(1)} ч)');
      score += 2;
    } else if (today.playHours > maxPlayHoursPerDay) {
      reasons.add('много игры сегодня (${today.playHours.toStringAsFixed(1)} ч)');
      score += 1;
    }

    // Игра за неделю
    if (playHoursThisWeek > maxPlayHoursPerWeek) {
      reasons.add('много часов за неделю (${playHoursThisWeek.toStringAsFixed(0)} ч)');
      score += 2;
    }

    // Подряд дни без отдыха (от сегодня назад)
    final sortedDates = days.map((d) => d.date).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    int consecutiveLoad = 0;
    for (final date in sortedDates) {
      if (date.compareTo(today.date) > 0) continue;
      final d = days.firstWhere((e) => e.date == date);
      if (d.playHours >= 2) {
        consecutiveLoad++;
      } else {
        break;
      }
    }
    if (consecutiveLoad >= consecutiveHighLoadDaysThreshold) {
      reasons.add('$consecutiveLoad дней подряд без отдыха');
      score += 2;
    }

    // Перерывы
    if (today.playHours >= 2 && today.breaksCount < minBreaksPerDay) {
      reasons.add('мало перерывов');
      score += 1;
    }

    // Настроение и серия поражений
    if (today.mood == Mood.bad) {
      reasons.add('плохое настроение после сессии');
      score += 2;
    }
    if (today.losingStreak >= losingStreakTiltThreshold) {
      reasons.add('серия поражений (${today.losingStreak})');
      score += 2;
    }

    final reason = reasons.isEmpty
        ? 'Всё в норме: нагрузка и перерывы в балансе.'
        : reasons.join('; ');
    String recommendation;
    BurnoutLevel level;

    if (score >= 5) {
      level = BurnoutLevel.red;
      recommendation =
          'Завтра без ranked — только анализ или выходной. Сегодня лучше остановиться.';
    } else if (score >= 2) {
      level = BurnoutLevel.yellow;
      recommendation =
          'Сократи время игры сегодня или сделай перерыв. Завтра заходи в игру отдохнувшим.';
    } else {
      level = BurnoutLevel.green;
      recommendation =
          'Держи текущий ритм. Не забывай про перерывы.';
    }

    return BurnoutResult(
      level: level,
      reason: reason,
      recommendation: recommendation,
    );
  }
}
