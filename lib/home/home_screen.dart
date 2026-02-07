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

/// Открывает экран как модальное окно на весь экран (как настройки/настроение).
void showFullScreenModal(BuildContext context, Widget child) {
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
      child: child,
    ),
  );
}

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
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
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
                            ],
                          ),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: spacingXs, vertical: spacingS),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(radiusCard),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Material(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(radiusButton),
                  child: InkWell(
                    onTap: () {
                      if (isActive) {
                        _showEndSessionDialog(context);
                      } else {
                        appState.startSession();
                        context.read<PauseReminder>().startSessionTimer(() {
                          appState.requestWellnessReminder();
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(radiusButton),
                    child: SizedBox(
                      height: 56,
                      child: Center(
                        child: Icon(
                          isActive ? Icons.stop_rounded : Icons.play_arrow_rounded,
                          size: 36,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: spacingXs),
              Expanded(
                child: _MinimalIndicator(
                  appState: appState,
                  onTap: () => showFullScreenModal(context, const StateScreen()),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: spacingXs, vertical: spacingS),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(radiusCard),
          ),
          child: Row(
            children: [
              Expanded(
                child: _IconBtn(
                  icon: Icons.local_fire_department_rounded,
                  tooltip: 'Тильт',
                  color: Colors.white,
                  onTap: () {
                    appState.triggerTiltFromUi();
                    showAntiTiltIfNeeded(context, appState);
                  },
                  minHeight: 52,
                  iconSize: 30,
                ),
              ),
              const SizedBox(width: spacingXs),
              Expanded(
                child: _MoodSingleBtn(
                  appState: appState,
                  minHeight: 52,
                  onTap: () => _openMoodModal(context),
                ),
              ),
              const SizedBox(width: spacingXs),
              Expanded(
                child: _IconBtn(
                  icon: Icons.settings_rounded,
                  tooltip: 'Настройки',
                  onTap: () => _openSettingsModal(context),
                  minHeight: 52,
                  iconSize: 30,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openSettingsModal(BuildContext context) {
    showFullScreenModal(context, const SettingsScreen());
  }

  void _openMoodModal(BuildContext context) {
    showFullScreenModal(context, const MoodScreen());
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
              contentPadding: const EdgeInsets.symmetric(horizontal: spacingXl, vertical: spacingL),
              content: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxContentH),
                child: SingleChildScrollView(
                  child: myPlay == null
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Как сыграл ты?',
                              style: Theme.of(ctx).textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: spacingL),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Как сыграла команда?',
                              style: Theme.of(ctx).textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: spacingL),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
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
  const _MoodSingleBtn({
    required this.appState,
    this.minHeight = 36,
    required this.onTap,
  });

  final AppState appState;
  final double minHeight;
  final VoidCallback onTap;

  static const String _emoticonPath = 'windows/runner/resources/emoticon';
  static const _emoticons = {
    Mood.bad: '$_emoticonPath/3.png',
    Mood.ok: '$_emoticonPath/1.png',
    Mood.good: '$_emoticonPath/2.png',
  };

  @override
  Widget build(BuildContext context) {
    final current = appState.todayRecord.mood;
    final asset = current != null ? _emoticons[current]! : '$_emoticonPath/1.png';
    return Tooltip(
      message: 'Настроение',
      child: Material(
        color: current != null
            ? Theme.of(context).colorScheme.surfaceContainerLowest
            : Colors.transparent,
        borderRadius: BorderRadius.circular(radiusCard),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radiusCard),
          child: SizedBox(
            height: minHeight,
            child: Center(
              child: Image.asset(
                asset,
                width: 32,
                height: 32,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.mood_rounded,
                  size: 28,
                  color: current != null
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
                ),
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
  const _MinimalIndicator({required this.appState, required this.onTap});

  final AppState appState;
  final VoidCallback onTap;

  static const String _hpPath = 'windows/runner/resources/hp';

  /// Уровень HP-бара: 1 = полный (зелёный), 4 = минимальный (красный).
  static int _hpLevel(BurnoutLevel level) {
    return switch (level) {
      BurnoutLevel.green => 1,
      BurnoutLevel.yellow => 2,
      BurnoutLevel.red => 4,
    };
  }

  static String _hpAsset(int level) => '$_hpPath/$level.png';

  /// Короткая подпись под HP-баром (2–3 слова по уровню).
  static String _shortLabel(BurnoutLevel level) {
    return switch (level) {
      BurnoutLevel.green => 'Ты в потоке',
      BurnoutLevel.yellow => 'Время отдохнуть',
      BurnoutLevel.red => 'Остановись, отдохни',
    };
  }

  @override
  Widget build(BuildContext context) {
    final result = appState.getBurnoutResult();
    final scheme = Theme.of(context).colorScheme;
    final mood = appState.todayRecord.mood;
    final hpLevel = mood == Mood.bad ? 4 : _hpLevel(result.level);
    const barHeight = 44.0;

    return Material(
      color: scheme.surfaceContainer,
      borderRadius: BorderRadius.circular(radiusCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radiusCard),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: spacingS, vertical: spacingS),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image.asset(
                  _hpAsset(hpLevel),
                  height: barHeight,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => SizedBox(height: barHeight, width: 180),
                ),
              ),
              const SizedBox(height: spacingXs),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _shortLabel(mood == Mood.bad ? BurnoutLevel.red : result.level),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
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
    this.iconSize = 28,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? color;
  final double minHeight;
  final double iconSize;

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
              child: Icon(icon, size: iconSize, color: color ?? Theme.of(context).iconTheme.color),
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

