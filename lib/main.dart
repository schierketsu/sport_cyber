import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';
import 'core/storage.dart';
import 'state/app_state.dart';
import 'features/wellness/pause_reminder.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
    await windowManager.ensureInitialized();
    const windowSize = Size(400, 200);
    await windowManager.setSize(windowSize);
    await windowManager.setMinimumSize(windowSize);
    await windowManager.setMaximumSize(windowSize);
    await windowManager.setResizable(false);
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setAsFrameless();
    await windowManager.setAlignment(Alignment.bottomRight);
  }

  final storage = await AppStorage.create();
  final appState = AppState(storage);
  final pauseReminder = PauseReminder(storage);
  await pauseReminder.init();
  runApp(CyberTrainerApp(appState: appState, pauseReminder: pauseReminder));
}
