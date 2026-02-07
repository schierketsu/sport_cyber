import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models.dart';
import '../../core/theme.dart';
import '../../state/app_state.dart';

/// Полноэкранное окно «Статистика»: график каток по времени, цвет = качество, тап по столбику — детали.
class StateScreen extends StatelessWidget {
  const StateScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                      'Катки за день',
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: Consumer<AppState>(
                builder: (context, appState, _) {
                  final today = appState.todayRecord;
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return Padding(
                        padding: const EdgeInsets.all(spacingM),
                        child: _SessionsChart(
                          date: today.date,
                          sessions: today.sessions,
                          maxHeight: constraints.maxHeight,
                          onSessionTap: (session) => _showSessionDetail(context, session),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSessionDetail(BuildContext context, SessionRecord session) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = _qualityColor(scheme, session);
    final startH = session.startMinutes ~/ 60;
    final startM = session.startMinutes % 60;
    final endH = session.endMinutes ~/ 60;
    final endM = session.endMinutes % 60;
    final durationMin = session.durationMinutes;
    final durationStr =
        durationMin >= 60
            ? '${durationMin ~/ 60} ч ${durationMin % 60} мин'
            : '$durationMin мин';

    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        final maxContentHeight = MediaQuery.sizeOf(ctx).height * 0.35;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(height: 32),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxContentHeight),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(spacingL, 0, spacingL, spacingL),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: spacingS),
                          Text('Катка', style: theme.textTheme.titleSmall),
                        ],
                      ),
                      const SizedBox(height: spacingM),
                      Text(
                        'Время: ${startH.toString().padLeft(2, '0')}:${startM.toString().padLeft(2, '0')} — ${endH.toString().padLeft(2, '0')}:${endM.toString().padLeft(2, '0')}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text('Длительность: $durationStr', style: theme.textTheme.bodyMedium),
                      if (session.myPlaySatisfied != null)
                        Text(
                          'Ты: ${session.myPlaySatisfied! ? "👍" : "👎"}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      if (session.teamPlaySatisfied != null)
                        Text(
                          'Команда: ${session.teamPlaySatisfied! ? "👍" : "👎"}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      if (session.mood != null)
                        Text(
                          'Настроение: ${_moodLabel(session.mood!)}',
                          style: theme.textTheme.bodyMedium,
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
  },
    );
  }

  String _moodLabel(Mood m) {
    return switch (m) {
      Mood.bad => 'плохо',
      Mood.ok => 'норм',
      Mood.good => 'хорошо',
    };
  }

  Color _qualityColor(ColorScheme scheme, SessionRecord s) {
    final my = s.myPlaySatisfied;
    final team = s.teamPlaySatisfied;
    final mood = s.mood;
    if (my == false || team == false || mood == Mood.bad) return scheme.burnoutRed;
    if (my == true && team == true) return scheme.burnoutGreen;
    if (mood == Mood.good) return scheme.burnoutGreen;
    return scheme.burnoutYellow;
  }
}

const int _minutesPerDay = 24 * 60;

class _SessionsChart extends StatelessWidget {
  const _SessionsChart({
    required this.date,
    required this.sessions,
    this.maxHeight,
    required this.onSessionTap,
  });

  final String date;
  final List<SessionRecord> sessions;
  final double? maxHeight;
  final void Function(SessionRecord) onSessionTap;

  static const double _labelHeight = 20.0;
  static const double _barGap = 4.0;
  static const double _minBarHeight = 14.0;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: spacingXl),
        child: Text(
          'Пока нет каток за сегодня. Завершите сессию (Стоп), чтобы она появилась здесь.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final n = sessions.length;
    final double barHeight;
    if (maxHeight != null && maxHeight! > 0) {
      const topLabel = _labelHeight + spacingXs;
      const bottomLabels = _labelHeight + spacingXs + spacingM + 28;
      final forBars = maxHeight! - topLabel - bottomLabels - spacingS;
      barHeight = ((forBars / n) - _barGap).clamp(_minBarHeight, 36.0);
    } else {
      barHeight = 28.0;
    }
    final totalHeight = n * (barHeight + _barGap) + _labelHeight + spacingS;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '0:00',
          style: theme.textTheme.labelSmall,
        ),
        const SizedBox(height: spacingXs),
        SizedBox(
          height: totalHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return Stack(
                children: [
                  _TimeGrid(width: width, height: totalHeight - _labelHeight),
                  ...List.generate(sessions.length, (i) {
                    final s = sessions[i];
                    final y = _labelHeight + i * (barHeight + _barGap);
                    final left = (s.startMinutes / _minutesPerDay) * width;
                    final barWidth = (s.durationMinutes / _minutesPerDay) * width;
                    final color = _barColor(scheme, s);
                    return Positioned(
                      left: left,
                      top: y,
                      width: barWidth.clamp(4.0, width),
                      height: barHeight,
                      child: Material(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                        child: InkWell(
                          onTap: () => onSessionTap(s),
                          borderRadius: BorderRadius.circular(4),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: spacingXs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0:00', style: theme.textTheme.labelSmall),
            Text('12:00', style: theme.textTheme.labelSmall),
            Text('24:00', style: theme.textTheme.labelSmall),
          ],
        ),
        const SizedBox(height: spacingM),
        Row(
          children: [
            _LegendItem(color: scheme.burnoutGreen, label: 'Хорошо'),
            const SizedBox(width: spacingL),
            _LegendItem(color: scheme.burnoutYellow, label: 'Норм'),
            const SizedBox(width: spacingL),
            _LegendItem(color: scheme.burnoutRed, label: 'Плохо'),
          ],
        ),
      ],
    );
  }

  Color _barColor(ColorScheme scheme, SessionRecord s) {
    final my = s.myPlaySatisfied;
    final team = s.teamPlaySatisfied;
    final mood = s.mood;
    if (my == false || team == false || mood == Mood.bad) return scheme.burnoutRed;
    if (my == true && team == true) return scheme.burnoutGreen;
    if (mood == Mood.good) return scheme.burnoutGreen;
    return scheme.burnoutYellow;
  }
}

class _TimeGrid extends StatelessWidget {
  const _TimeGrid({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      width: width,
      height: height,
      child: CustomPaint(
        painter: _GridPainter(),
        size: Size(width, height),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white12
      ..strokeWidth = 1;
    for (int hour = 1; hour < 24; hour++) {
      final x = (hour / 24) * size.width;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: spacingS),
        Text(label, style: theme.labelSmall),
      ],
    );
  }
}
