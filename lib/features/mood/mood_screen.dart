import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models.dart';
import '../../core/theme.dart';
import '../../state/app_state.dart';

/// Полноэкранный выбор настроения: три иконки в ряд, без подписей.
class MoodScreen extends StatelessWidget {
  const MoodScreen({super.key});

  static const _icons = {
    Mood.bad: Icons.sentiment_dissatisfied_rounded,
    Mood.ok: Icons.sentiment_neutral_rounded,
    Mood.good: Icons.sentiment_satisfied_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final current = appState.todayRecord.mood;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        title: Text(
          'Настроение',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => Navigator.pop(context),
          style: IconButton.styleFrom(minimumSize: const Size(40, 40)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingM),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final mood in Mood.values)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: spacingS),
                  child: _MoodIconButton(
                    icon: _icons[mood]!,
                    selected: current == mood,
                    onTap: () {
                      appState.setTodayMood(mood);
                      Navigator.pop(context);
                    },
                    color: mood == Mood.bad
                        ? scheme.burnoutRed
                        : mood == Mood.ok
                            ? scheme.burnoutYellow
                            : scheme.burnoutGreen,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MoodIconButton extends StatelessWidget {
  const _MoodIconButton({
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected
          ? color.withValues(alpha: 0.25)
          : scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(radiusCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radiusCard),
        child: SizedBox(
          height: 72,
          child: Center(
            child: Icon(
              icon,
              size: 48,
              color: selected ? color : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
