import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'exercise_screen.dart';

/// Экран выбора: 4 большие иконки (Кисти, Шея, Спина, Глаза). По тапу — полноэкранное окно с упражнением.
class WellnessScreen extends StatelessWidget {
  const WellnessScreen({super.key});

  static const double _iconSize = 48;

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
                      'Выберите что размять',
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
                padding: const EdgeInsets.all(spacingL),
                child: Row(
                  children: [
                    Expanded(child: _WellnessIconTile(
                      icon: Icons.back_hand_rounded,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const ExerciseScreen(
                            title: 'Кисти',
                            description: 'Круговые движения кистями, сжатие и разжатие пальцев.',
                            durationSeconds: 45,
                          ),
                        ),
                      ),
                    )),
                    const SizedBox(width: spacingS),
                    Expanded(child: _WellnessIconTile(
                      icon: Icons.face_rounded,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const ExerciseScreen(
                            title: 'Шея',
                            description: 'Медленные наклоны головы влево-вправо и вперёд-назад.',
                            durationSeconds: 45,
                          ),
                        ),
                      ),
                    )),
                    const SizedBox(width: spacingS),
                    Expanded(child: _WellnessIconTile(
                      icon: Icons.airline_seat_recline_normal_rounded,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const ExerciseScreen(
                            title: 'Спина',
                            description: 'Прогиб спины сидя, лёгкие скручивания корпуса.',
                            durationSeconds: 45,
                          ),
                        ),
                      ),
                    )),
                    const SizedBox(width: spacingS),
                    Expanded(child: _WellnessIconTile(
                      icon: Icons.remove_red_eye_rounded,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const Eyes202020Screen(),
                        ),
                      ),
                    )),
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

class _WellnessIconTile extends StatelessWidget {
  const _WellnessIconTile({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainer,
      borderRadius: BorderRadius.circular(radiusCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radiusCard),
        child: Center(
          child: Icon(icon, size: WellnessScreen._iconSize, color: Colors.white),
        ),
      ),
    );
  }
}

/// Полноэкранное окно: правило 20-20-20, описание и таймер 20 сек.
class Eyes202020Screen extends StatefulWidget {
  const Eyes202020Screen({super.key});

  @override
  State<Eyes202020Screen> createState() => _Eyes202020ScreenState();
}

class _Eyes202020ScreenState extends State<Eyes202020Screen> {
  static const int _total = 20;
  int _remaining = _total;

  @override
  void initState() {
    super.initState();
    _tick();
  }

  void _tick() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        if (_remaining > 0) _remaining--;
      });
      if (_remaining > 0) _tick();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
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
                      '20-20-20',
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: spacingXl, vertical: spacingL),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(radiusCard),
                      ),
                      child: Text(
                        '$_remaining сек',
                        style: theme.textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: spacingL),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: spacingL),
                      child: Text(
                        'Каждые 20 минут — 20 секунд смотри вдаль на объект в 20 метрах. Снижает усталость глаз.',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
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
