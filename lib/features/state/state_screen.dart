import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models.dart';
import '../../core/theme.dart';
import '../../state/app_state.dart';

const int _minutesPerDay = 24 * 60;

/// Окно «Катки за день»: график сессий по времени, тап по полоске — детали. Без переполнения, компактно.
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
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(spacingM, 0, spacingM, spacingM),
                    child: _SessionsChart(
                      sessions: today.sessions,
                      onSessionTap: (session) => _showSessionDetail(context, session),
                    ),
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
      backgroundColor: scheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radiusCard)),
      ),
      builder: (ctx) {
        final maxContentHeight = MediaQuery.sizeOf(ctx).height * 0.4;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(height: 28),
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

class _SessionsChart extends StatelessWidget {
  const _SessionsChart({
    required this.sessions,
    required this.onSessionTap,
  });

  final List<SessionRecord> sessions;
  final void Function(SessionRecord) onSessionTap;

  static const double _barGap = 3.0;
  static const double _minBarHeight = 6.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (sessions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(spacingL),
          child: Text(
            'Пока нет каток за сегодня.\nЗавершите сессию (Стоп), чтобы она появилась здесь.',
            style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Верхняя шкала времени
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0:00', style: theme.textTheme.labelSmall),
            Text('12:00', style: theme.textTheme.labelSmall),
            Text('24:00', style: theme.textTheme.labelSmall),
          ],
        ),
        const SizedBox(height: spacingXs),
        // График — занимает всё оставшееся место, без переполнения
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;
              final n = sessions.length;
              final barHeight = ((h / n) - _barGap).clamp(_minBarHeight, 40.0);
              final barAreaHeight = n * (barHeight + _barGap);

              return Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  // Сетка по часам
                  Positioned(
                    left: 0,
                    top: 0,
                    width: w,
                    height: barAreaHeight,
                    child: CustomPaint(
                      painter: _GridPainter(),
                      size: Size(w, barAreaHeight),
                    ),
                  ),
                  // Полоски сессий
                  ...List.generate(n, (i) {
                    final s = sessions[i];
                    final y = i * (barHeight + _barGap);
                    final left = (s.startMinutes / _minutesPerDay) * w;
                    final barW = (s.durationMinutes / _minutesPerDay) * w;
                    final color = _barColor(scheme, s);
                    return Positioned(
                      left: left,
                      top: y,
                      width: barW.clamp(4.0, w),
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
        const SizedBox(height: spacingS),
        // Легенда в одну строку, компактно
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendItem(color: scheme.burnoutGreen, label: 'Хорошо'),
            const SizedBox(width: spacingM),
            _LegendItem(color: scheme.burnoutYellow, label: 'Норм'),
            const SizedBox(width: spacingM),
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
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: spacingXs),
        Text(label, style: theme.labelSmall),
      ],
    );
  }
}
