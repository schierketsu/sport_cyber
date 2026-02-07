import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../core/storage.dart';

/// Логика напоминаний о wellness-паузах.
/// В прототипе: показ уведомления через N минут после старта сессии (таймер в приложении).
class PauseReminder {
  PauseReminder(this._storage);

  final AppStorage _storage;
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  Timer? _timer;

  static const AndroidNotificationDetails _androidDetails = AndroidNotificationDetails(
    'wellness_pause',
    'Wellness-паузы',
    channelDescription: 'Напоминания о перерывах и упражнениях',
  );

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);
    await _plugin.initialize(initSettings);

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      const channel = AndroidNotificationChannel(
        'wellness_pause',
        'Wellness-паузы',
        description: 'Напоминания о перерывах',
        importance: Importance.low,
      );
      await androidPlugin.createNotificationChannel(channel);
    }
  }

  bool get enabled => _storage.getWellnessReminderEnabled();
  int get intervalMinutes => _storage.getWellnessReminderMinutes();

  void startSessionTimer(void Function() onRemind) {
    _timer?.cancel();
    if (!enabled) return;
    _timer = Timer(Duration(minutes: intervalMinutes), () {
      onRemind();
      showNow();
    });
  }

  void cancelSessionTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> showNow() async {
    await _plugin.show(
      0,
      'КИБЕРКАЧАЛКА',
      'Время паузы: правило 20-20-20 или пару упражнений для глаз и спины.',
      const NotificationDetails(android: _androidDetails),
    );
  }

  Future<void> cancelAll() async {
    _timer?.cancel();
    _timer = null;
    await _plugin.cancelAll();
  }
}
