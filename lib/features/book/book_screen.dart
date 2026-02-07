import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// Плитка главного раздела гайдов (ОСНОВЫ / РАСКИДКИ).
class _MainTile extends StatelessWidget {
  const _MainTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(radiusCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radiusCard),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingXl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: spacingS),
              Text(
                label,
                style: theme.textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Экран «Гайды» — две главные плитки: ОСНОВЫ и РАСКИДКИ.
class BookScreen extends StatelessWidget {
  const BookScreen({super.key});

  static const List<String> _basicsTitles = [
    'Как не умирать первым каждый раунд',
    'Экономика раундов: когда эко, когда форс',
    'Тайминги на картах: когда враг уже на точке',
  ];

  static const List<String> _spreadsTitles = [
    'Лучшие раскидки для DUST2',
  ];

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
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Гайды',
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingM),
              child: Row(
                children: [
                  Expanded(
                    child: _MainTile(
                      icon: Icons.school_rounded,
                      label: 'ОСНОВЫ',
                      onTap: () => _openSection(context, 'ОСНОВЫ', _basicsTitles),
                    ),
                  ),
                  const SizedBox(width: spacingM),
                  Expanded(
                    child: _MainTile(
                      icon: Icons.map_rounded,
                      label: 'РАСКИДКИ',
                      onTap: () => _openSection(context, 'РАСКИДКИ', _spreadsTitles),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openSection(BuildContext context, String sectionTitle, List<String> items) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => _BookSectionScreen(
          title: sectionTitle,
          items: items,
        ),
      ),
    );
  }
}

/// Экран раздела гайдов — список статей (ОСНОВЫ или РАСКИДКИ).
class _BookSectionScreen extends StatelessWidget {
  const _BookSectionScreen({
    required this.title,
    required this.items,
  });

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = Theme.of(context).colorScheme;
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
                      title,
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(spacingL, spacingS, spacingL, spacingL),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: spacingS),
                itemBuilder: (context, index) {
                  return Material(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(radiusCard),
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(radiusCard),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingM),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                items[index],
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded, size: 22, color: scheme.onSurfaceVariant),
                          ],
                        ),
                      ),
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
}
