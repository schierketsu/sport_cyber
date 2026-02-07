import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../state/app_state.dart';

/// Полноэкранный антитильт: вопрос и кнопки действий.
class AntiTiltScreen extends StatelessWidget {
  const AntiTiltScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: spacingS, vertical: spacingXs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 22),
                    onPressed: () => _close(context, appState),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(40, 40),
                      padding: const EdgeInsets.all(spacingS),
                    ),
                  ),
                  const SizedBox(width: spacingXs),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'Сейчас ты играешь хуже не из-за скилла. Хочешь остановиться и сохранить рейтинг?',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: spacingM),
              FilledButton.tonal(
                onPressed: () {
                  _close(context, appState);
                  Navigator.pushNamed(context, '/wellness');
                },
                style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
                child: const Text('Физическая разрядка'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _close(BuildContext context, AppState appState) {
    appState.dismissTiltDialog();
    Navigator.of(context).pop();
  }
}
