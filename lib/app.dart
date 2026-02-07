import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'state/app_state.dart';
import 'home/home_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/wellness/wellness_screen.dart';
import 'features/state/state_screen.dart';
import 'features/mood/mood_screen.dart';
import 'features/wellness/pause_reminder.dart';

class CyberTrainerApp extends StatelessWidget {
  const CyberTrainerApp({
    super.key,
    required this.appState,
    required this.pauseReminder,
  });

  final AppState appState;
  final PauseReminder pauseReminder;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: appState),
        Provider<PauseReminder>.value(value: pauseReminder),
      ],
      child: MaterialApp(
        title: 'КИБЕРКАЧАЛКА',
        theme: appDarkTheme,
        debugShowCheckedModeBanner: false,
        builder: (context, child) => Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: Theme.of(context).colorScheme.surface,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(radiusCard),
              child: child,
            ),
          ],
        ),
        home: const HomeScreen(),
        routes: {
          '/settings': (context) => const SettingsScreen(),
          '/wellness': (context) => const WellnessScreen(),
          '/state': (context) => const StateScreen(),
          '/mood': (context) => const MoodScreen(),
        },
      ),
    );
  }
}

/// При тильте сразу открываем «Физическая разрядка» (wellness) как модальное окно, как настройки.
void showAntiTiltIfNeeded(BuildContext context, AppState appState) {
  if (!appState.tiltDialogActive) return;
  if (appState.antiTiltScreenShowing) return;
  appState.markAntiTiltScreenShowing();
  appState.dismissTiltDialog();
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(radiusCard)),
      ),
      child: const WellnessScreen(),
    ),
  ).then((_) => appState.clearAntiTiltScreenShowing());
}
