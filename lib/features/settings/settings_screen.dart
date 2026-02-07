import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../state/app_state.dart';
import '../planner/planner_settings.dart' as model;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _todaySleepController;
  late TextEditingController _todayWorkController;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    final today = appState.todayRecord;
    _todaySleepController = TextEditingController(
      text: today.sleepHours != null ? today.sleepHours!.round().toString() : '',
    );
    _todayWorkController = TextEditingController(
      text: today.breaksCount == 0 ? '' : today.breaksCount.toString(),
    );
  }

  @override
  void dispose() {
    _todaySleepController.dispose();
    _todayWorkController.dispose();
    super.dispose();
  }

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
                      'Настройки',
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth - spacingL * 2;
                  const buttonH = 52.0;
                  final tileAreaH = constraints.maxHeight - spacingL - buttonH - spacingL;
                  final tileSide = tileAreaH.clamp(40.0, (w - spacingM) / 2);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingM),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: tileSide,
                          child: Row(
                            children: [
                              Expanded(
                                child: _inputTile(context, _todaySleepController, icon: Icons.bed_rounded, hint: 'ч'),
                              ),
                              const SizedBox(width: spacingM),
                              Expanded(
                                child: _inputTile(context, _todayWorkController, icon: Icons.work_rounded, hint: 'ч'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: spacingL),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: FilledButton(
                            onPressed: () => _saveAll(context),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: spacingS),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusButton)),
                            ),
                            child: const Text('Сохранить'),
                          ),
                        ),
                      ],
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

  Widget _inputTile(BuildContext context, TextEditingController c, {required IconData icon, String hint = 'ч'}) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(spacingXs),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radiusCard),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.3), width: 1),
      ),
      child: ClipRect(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 34, color: scheme.onSurfaceVariant),
            const SizedBox(height: 2),
            Expanded(
              child: TextField(
                controller: c,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall,
                decoration: InputDecoration(
                  hintText: hint,
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveAll(BuildContext context) {
    final appState = context.read<AppState>();
    final settings = appState.plannerSettings ?? model.PlannerSettings();
    appState.setPlannerSettings(settings);
    final todaySleep = double.tryParse(_todaySleepController.text.trim());
    final todayBreaks = int.tryParse(_todayWorkController.text.trim());
    if (todaySleep != null) appState.setTodaySleep(todaySleep);
    appState.setTodayBreaks(todayBreaks ?? 0);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Сохранено'), duration: Duration(seconds: 1)),
    );
  }
}
