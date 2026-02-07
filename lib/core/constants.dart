// Пороги и константы для индикатора выгорания и антитильта.

// Игра (часы)
const double maxPlayHoursPerDay = 4.0;
const double maxPlayHoursPerWeek = 25.0;
const int consecutiveHighLoadDaysThreshold = 4;

// Сон (часы)
const double minSleepHours = 6.0;
const double criticalSleepHours = 5.0;

// Перерывы за день
const int minBreaksPerDay = 2;

// Серия поражений — порог для тильта
const int losingStreakTiltThreshold = 3;

// Интервал напоминания о wellness (минуты)
const int defaultWellnessReminderMinutes = 20;
