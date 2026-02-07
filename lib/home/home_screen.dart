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
import '../features/book/book_screen.dart';

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

/// После завершения катки предлагает пользователю размяться.
void _showWellnessOffer(BuildContext context) {
  final theme = Theme.of(context);
  final fillBtnStyle = FilledButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    padding: const EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingS),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusButton)),
  );
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(spacingXl, spacingL, spacingXl, spacingL),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Размяться?',
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: spacingM),
          Text(
            'Теперь за здоровье!',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: spacingXl),
          Center(
            child: FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                showFullScreenModal(context, const WellnessScreen());
              },
              style: fillBtnStyle,
              child: const Text('Делаем'),
            ),
          ),
        ],
      ),
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
      body: Consumer<AppState>(
        builder: (context, appState, _) {
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
                width: 88,
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
                      height: 64,
                      child: Center(
                        child: Icon(
                          isActive ? Icons.stop_rounded : Icons.play_arrow_rounded,
                          size: 48,
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
        const SizedBox(height: spacingM),
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
                child: _IconBtn(
                  icon: Icons.menu_book_rounded,
                  tooltip: 'Гайды',
                  onTap: () => showFullScreenModal(context, const BookScreen()),
                  minHeight: 52,
                  iconSize: 30,
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
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) _showWellnessOffer(context);
              });
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

  /// Порог "мало спал" (часов).
  static const double _littleSleepThreshold = 6.0;
  /// Порог "много работал" (часов).
  static const int _lotsOfWorkThreshold = 6;

  /// Уровень HP-бара: 1 = полный (зелёный), 2–3 = средний, 4 = минимальный (красный).
  static int _hpLevel(BurnoutLevel level) {
    return switch (level) {
      BurnoutLevel.green => 1,
      BurnoutLevel.yellow => 2,
      BurnoutLevel.red => 4,
    };
  }

  static String _hpAsset(int level) => '$_hpPath/$level.png';

  /// Короткая подпись под HP-баром (2–3 слова по уровню).
  static String _shortLabel(BurnoutLevel level, {
    bool sleepWorkMedium = false,
    bool losingStreakHigh = false,
  }) {
    if (losingStreakHigh) return 'Мигом отдыхать!';
    if (sleepWorkMedium) return 'Средняя форма';
    return switch (level) {
      BurnoutLevel.green => 'Ты в потоке!',
      BurnoutLevel.yellow => 'Время отдохнуть',
      BurnoutLevel.red => 'Остановись, отдохни',
    };
  }

  /// Лузстрик 1–2 → 3 HP; лузстрик > 3 → 4 HP и "Мигом отдыхать!".
  static bool _isLosingStreakWarn(int streak) => streak >= 1 && streak <= 2;
  static bool _isLosingStreakCritical(int streak) => streak > 3;

  /// Сон < 5 часов → всегда 0 HP и "Только спать!".
  static const double _veryLowSleepThreshold = 5.0;
  static bool _isVeryLowSleep(DayRecord today) {
    final sleep = today.sleepHours;
    return sleep != null && sleep < _veryLowSleepThreshold;
  }

  /// Мало спал и много работал → среднее состояние: 3 HP, подпись "Средняя форма".
  static bool _isSleepWorkTired(DayRecord today) {
    final sleep = today.sleepHours;
    if (sleep == null || sleep >= _littleSleepThreshold) return false;
    return today.breaksCount >= _lotsOfWorkThreshold;
  }

  @override
  Widget build(BuildContext context) {
    final result = appState.getBurnoutResult();
    final scheme = Theme.of(context).colorScheme;
    final today = appState.todayRecord;
    final mood = today.mood;
    final streak = today.losingStreak;
    final veryLowSleep = _isVeryLowSleep(today);
    final sleepWorkMedium = _isSleepWorkTired(today);
    final losingCritical = _isLosingStreakCritical(streak);
    final losingWarn = _isLosingStreakWarn(streak);
    final int hpLevel;
    final String label;
    if (veryLowSleep) {
      hpLevel = 0;
      label = 'Только спать!';
    } else if (losingCritical) {
      hpLevel = 4;
      label = _shortLabel(result.level, losingStreakHigh: true);
    } else if (mood == Mood.bad) {
      hpLevel = 4;
      label = _shortLabel(BurnoutLevel.red);
    } else if (losingWarn) {
      hpLevel = 3;
      label = _shortLabel(BurnoutLevel.yellow);
    } else if (sleepWorkMedium) {
      hpLevel = 3;
      label = _shortLabel(result.level, sleepWorkMedium: true);
    } else {
      hpLevel = _hpLevel(result.level);
      label = _shortLabel(result.level);
    }
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
                  label,
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

