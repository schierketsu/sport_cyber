import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../core/models.dart';
import '../core/theme.dart';
import '../state/app_state.dart';
import '../app.dart';
import '../features/burnout/burnout_indicator.dart';
import '../features/wellness/pause_reminder.dart';
import '../features/wellness/wellness_screen.dart';
import '../features/wellness/exercise_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/state/state_screen.dart';
import '../features/mood/mood_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTiltAndShowDialog(context);
    });
  }

  void _checkTiltAndShowDialog(BuildContext context) {
    final appState = context.read<AppState>();
    if (appState.tiltDialogActive) {
      showAntiTiltIfNeeded(context, appState);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: context.watch<AppState>(),
        builder: (context, _) {
          final appState = context.read<AppState>();
          if (appState.tiltDialogActive) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showAntiTiltIfNeeded(context, appState);
            });
          }
          final bottomInset = MediaQuery.of(context).padding.top + spacingXs;
          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: spacingXs, vertical: spacingXs),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows)
                              DragToMoveArea(
                                child: _StartStopRow(appState: appState),
                              )
                            else
                              _StartStopRow(appState: appState),
                            if (_limitWarning(appState) != null) ...[
                              const SizedBox(height: spacingXs),
                              Text(
                                _limitWarning(appState)!,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ],
                            const SizedBox(height: spacingXs),
                            _MinimalIndicator(appState: appState),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: bottomInset),
                ],
              ),
              if (appState.wellnessReminderVisible)
                _WellnessReminderBanner(appState: appState),
            ],
          );
        },
      ),
    );
  }

  String? _limitWarning(AppState appState) {
    final settings = appState.plannerSettings;
    if (settings == null) return null;
    final played = appState.todayRecord.playHours;
    final limit = settings.maxPlayHoursPerDay;
    if (played >= limit) {
      return 'Лимит ${limit.toStringAsFixed(0)} ч — уже ${played.toStringAsFixed(1)} ч';
    }
    final remaining = limit - played;
    if (remaining <= 0.5 && remaining > 0) {
      return 'Осталось ~${(remaining * 60).round()} мин до лимита';
    }
    return null;
  }
}

class _StartStopRow extends StatelessWidget {
  const _StartStopRow({required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final isActive = appState.isSessionActive;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: spacingS, vertical: spacingM),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radiusCard),
      ),
      child: Row(
        children: [
          Expanded(
            child: FilledButton(
              onPressed: () {
                if (isActive) {
                  _showEndSessionDialog(context);
                } else {
                  appState.startSession();
                  context.read<PauseReminder>().startSessionTimer(() {
                    appState.requestWellnessReminder();
                  });
                }
              },
              style: FilledButton.styleFrom(minimumSize: const Size(0, 56)),
              child: Text(isActive ? 'Стоп' : 'Старт'),
            ),
          ),
          const SizedBox(width: spacingXs),
          Expanded(
            child: _IconBtn(
              icon: Icons.settings_rounded,
              tooltip: 'Настройки',
              onTap: () => _openSettingsModal(context),
              minHeight: 56,
            ),
          ),
          const SizedBox(width: spacingXs),
          Expanded(
            child: _MoodSingleBtn(appState: appState, minHeight: 56),
          ),
          const SizedBox(width: spacingXs),
          Expanded(
            child: _IconBtn(
              icon: Icons.warning_amber_rounded,
              tooltip: 'Тильт',
              color: scheme.error,
              onTap: () {
                appState.triggerTiltFromUi();
                showAntiTiltIfNeeded(context, appState);
              },
              minHeight: 56,
            ),
          ),
        ],
      ),
    );
  }

  void _openSettingsModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(radiusCard)),
        ),
        child: const SettingsScreen(),
      ),
    );
  }

  void _showEndSessionDialog(BuildContext context) {
    bool? myPlay;
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final maxContentH = MediaQuery.sizeOf(ctx).height * 0.45;
        return StatefulBuilder(
          builder: (ctx, setState) {
            void finish(bool teamPlay) {
              context.read<PauseReminder>().cancelSessionTimer();
              context.read<AppState>().endSession(
                    mood: myPlay! ? Mood.good : Mood.bad,
                    myPlaySatisfied: myPlay,
                    teamPlaySatisfied: teamPlay,
                  );
              Navigator.pop(ctx);
            }

            return AlertDialog(
              contentPadding: const EdgeInsets.fromLTRB(spacingL, spacingM, spacingL, spacingM),
              content: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxContentH),
                child: SingleChildScrollView(
                  child: myPlay == null
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Как сыграл ты?', style: Theme.of(ctx).textTheme.titleSmall),
                            const SizedBox(height: spacingS),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                _ThumbButton(
                                  thumbDown: true,
                                  selected: false,
                                  onPressed: () => setState(() => myPlay = false),
                                ),
                                const SizedBox(width: spacingM),
                                _ThumbButton(
                                  thumbDown: false,
                                  selected: false,
                                  onPressed: () => setState(() => myPlay = true),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Как сыграла команда?', style: Theme.of(ctx).textTheme.titleSmall),
                            const SizedBox(height: spacingS),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                _ThumbButton(
                                  thumbDown: true,
                                  selected: false,
                                  onPressed: () => finish(false),
                                ),
                                const SizedBox(width: spacingM),
                                _ThumbButton(
                                  thumbDown: false,
                                  selected: false,
                                  onPressed: () => finish(true),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _MoodSingleBtn extends StatelessWidget {
  const _MoodSingleBtn({required this.appState, this.minHeight = 36});

  final AppState appState;
  final double minHeight;

  static const _icons = {
    Mood.bad: Icons.sentiment_dissatisfied_rounded,
    Mood.ok: Icons.sentiment_neutral_rounded,
    Mood.good: Icons.sentiment_satisfied_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final current = appState.todayRecord.mood;
    final icon = current != null ? _icons[current]! : Icons.mood_rounded;
    return Tooltip(
      message: 'Настроение',
      child: Material(
        color: current != null
            ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(radiusCard),
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const MoodScreen()),
          ),
          borderRadius: BorderRadius.circular(radiusCard),
          child: SizedBox(
            height: minHeight,
            child: Center(
              child: Icon(
                icon,
                size: 24,
                color: current != null
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThumbButton extends StatelessWidget {
  const _ThumbButton({
    required this.thumbDown,
    required this.onPressed,
    this.selected = false,
  });

  final bool thumbDown;
  final VoidCallback onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isError = thumbDown;
    return IconButton.filled(
      onPressed: onPressed,
      icon: Icon(thumbDown ? Icons.thumb_down_rounded : Icons.thumb_up_rounded),
      tooltip: thumbDown ? 'Плохо' : 'Хорошо',
      style: IconButton.styleFrom(
        backgroundColor: selected
            ? (isError ? theme.colorScheme.errorContainer : theme.colorScheme.primaryContainer)
            : theme.colorScheme.surfaceContainerHighest,
        foregroundColor: selected
            ? (isError ? theme.colorScheme.onErrorContainer : theme.colorScheme.onPrimaryContainer)
            : theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _MinimalIndicator extends StatelessWidget {
  const _MinimalIndicator({required this.appState});

  final AppState appState;

  static String _heartAsset(BurnoutLevel level) {
    return switch (level) {
      BurnoutLevel.green => 'windows/runner/resources/greenheart.png',
      BurnoutLevel.yellow => 'windows/runner/resources/yellowheart.png',
      BurnoutLevel.red => 'windows/runner/resources/redheart.png',
    };
  }

  static String _statusLabel(BurnoutLevel level) {
    return switch (level) {
      BurnoutLevel.green => 'Баланс',
      BurnoutLevel.yellow => 'Перегруз',
      BurnoutLevel.red => 'Риск',
    };
  }

  @override
  Widget build(BuildContext context) {
    final result = appState.getBurnoutResult();
    final scheme = Theme.of(context).colorScheme;

    final levelColor = switch (result.level) {
      BurnoutLevel.green => scheme.burnoutGreen,
      BurnoutLevel.yellow => scheme.burnoutYellow,
      BurnoutLevel.red => scheme.burnoutRed,
    };

    const double panelHeight = 56 + spacingM * 2; // как у панели навигации (56 + vertical padding)
    return Material(
      color: scheme.surfaceContainer,
      borderRadius: BorderRadius.circular(radiusCard),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const StateScreen()),
        ),
        borderRadius: BorderRadius.circular(radiusCard),
        child: SizedBox(
          height: panelHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: spacingS, vertical: spacingM),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  _heartAsset(result.level),
                  width: 44,
                  height: 44,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: spacingS),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _statusLabel(result.level),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(color: levelColor, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        result.recommendation,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color,
    this.minHeight = 36,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? color;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radiusCard),
          child: SizedBox(
            height: minHeight,
            child: Center(
              child: Icon(icon, size: 24, color: color ?? Theme.of(context).iconTheme.color),
            ),
          ),
        ),
      ),
    );
  }
}

class _WellnessReminderBanner extends StatelessWidget {
  const _WellnessReminderBanner({required this.appState});

  final AppState appState;

  static const _messages = {
    'neck': 'Время размять шею',
    'wrists': 'Время размять кисти',
    'back': 'Время размять спину',
    'eyes': 'Время дать отдых глазам (20-20-20)',
  };

  @override
  Widget build(BuildContext context) {
    final message = _messages[appState.wellnessReminderType] ?? _messages['neck']!;
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: Material(
        elevation: 6,
        color: scheme.primaryContainer.withValues(alpha: 0.95),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: spacingS, vertical: spacingS),
            child: Row(
              children: [
                Icon(Icons.self_improvement_rounded, color: scheme.primary, size: 22),
                const SizedBox(width: spacingS),
                Expanded(
                  child: Text(
                    message,
                    style: theme.textTheme.labelLarge?.copyWith(color: scheme.onSurface),
                  ),
                ),
                FilledButton(
                  onPressed: () => _onStart(context),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingS),
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text('ПРИСТУПИТЬ', style: TextStyle(fontSize: 12)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => appState.dismissWellnessReminder(),
                  style: IconButton.styleFrom(padding: const EdgeInsets.all(spacingXs), minimumSize: Size.zero),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onStart(BuildContext context) {
    final type = appState.wellnessReminderType;
    appState.dismissWellnessReminder();
    switch (type) {
      case 'neck':
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => const ExerciseScreen(
              title: 'Шея',
              description: 'Медленные наклоны головы влево-вправо и вперёд-назад.',
              durationSeconds: 45,
            ),
          ),
        );
        break;
      case 'wrists':
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => const ExerciseScreen(
              title: 'Кисти',
              description: 'Круговые движения кистями, сжатие и разжатие пальцев.',
              durationSeconds: 45,
            ),
          ),
        );
        break;
      case 'back':
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => const ExerciseScreen(
              title: 'Спина',
              description: 'Прогиб спины сидя, лёгкие скручивания корпуса.',
              durationSeconds: 45,
            ),
          ),
        );
        break;
      case 'eyes':
        Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (context) => const WellnessScreen()),
        );
        break;
      default:
        Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (context) => const WellnessScreen()),
        );
    }
  }
}

