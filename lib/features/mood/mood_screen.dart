import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models.dart';
import '../../core/theme.dart';
import '../../state/app_state.dart';

/// Полноэкранный выбор настроения: три эмотикона в ряд, без подписей.
class MoodScreen extends StatelessWidget {
  const MoodScreen({super.key});

  static const String _emoticonPath = 'windows/runner/resources/emoticon';
  static const _emoticons = {
    Mood.bad: '$_emoticonPath/3.png',
    Mood.ok: '$_emoticonPath/1.png',
    Mood.good: '$_emoticonPath/2.png',
  };

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final current = appState.todayRecord.mood;
    final scheme = Theme.of(context).colorScheme;

    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: spacingS, vertical: spacingXs),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 22),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(minimumSize: const Size(40, 40)),
                  ),
                  Expanded(
                    child: Text(
                      'Настроение',
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingM),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (final mood in Mood.values)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: spacingS),
                          child: _MoodIconButton(
                            imageAsset: _emoticons[mood]!,
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
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodIconButton extends StatelessWidget {
  const _MoodIconButton({
    required this.imageAsset,
    required this.selected,
    required this.onTap,
    required this.color,
  });

  final String imageAsset;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected
          ? scheme.surfaceContainerLowest
          : scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(radiusCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radiusCard),
        child: SizedBox(
          height: 72,
          child: Center(
            child: Image.asset(
              imageAsset,
              width: 48,
              height: 48,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.mood_rounded,
                size: 48,
                color: selected ? color : scheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
