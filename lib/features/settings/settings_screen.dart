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
  late TextEditingController _workController;
  late TextEditingController _sleepController;
  late TextEditingController _maxPlayController;
  late TextEditingController _todaySleepController;
  late TextEditingController _todayBreaksController;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    final settings = appState.plannerSettings ?? model.PlannerSettings();
    final today = appState.todayRecord;
    _workController = TextEditingController(
      text: settings.workHoursPerDay?.toString() ?? '',
    );
    _sleepController = TextEditingController(
      text: settings.sleepGoalHours.toString(),
    );
    _maxPlayController = TextEditingController(
      text: settings.maxPlayHoursPerDay.toString(),
    );
    _todaySleepController = TextEditingController(
      text: today.sleepHours?.toString() ?? '',
    );
    _todayBreaksController = TextEditingController(
      text: today.breaksCount.toString(),
    );
  }

  @override
  void dispose() {
    _workController.dispose();
    _sleepController.dispose();
    _maxPlayController.dispose();
    _todaySleepController.dispose();
    _todayBreaksController.dispose();
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
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingS),
                children: [
                  _sectionTitle(context, 'Лимиты'),
                  const SizedBox(height: spacingS),
                  _field('Макс. игра (ч/день)', _maxPlayController, hint: '3'),
                  const SizedBox(height: spacingS),
                  _field('Сон цель (ч)', _sleepController, hint: '7'),
                  const SizedBox(height: spacingS),
                  _field('Работа/учеба (ч)', _workController, hint: 'пусто'),
                  const SizedBox(height: spacingM),
                  _sectionTitle(context, 'Сегодня'),
                  const SizedBox(height: spacingS),
                  _field('Сон (ч)', _todaySleepController, hint: '—'),
                  const SizedBox(height: spacingS),
                  _field('Перерывы', _todayBreaksController, hint: '0'),
                  const SizedBox(height: spacingL),
                  FilledButton(
                    onPressed: () => _saveAll(context),
                    child: const Text('Сохранить'),
                  ),
                  const SizedBox(height: spacingXl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _field(String label, TextEditingController c, {String hint = ''}) {
    return TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusField)),
      ),
    );
  }

  void _saveAll(BuildContext context) {
    final appState = context.read<AppState>();
    final work = double.tryParse(_workController.text.trim());
    final sleep = double.tryParse(_sleepController.text.trim()) ?? 7.0;
    final maxPlay = double.tryParse(_maxPlayController.text.trim()) ?? 3.0;
    appState.setPlannerSettings(model.PlannerSettings(
      workHoursPerDay: work,
      sleepGoalHours: sleep,
      maxPlayHoursPerDay: maxPlay,
    ));
    final todaySleep = double.tryParse(_todaySleepController.text.trim());
    final todayBreaks = int.tryParse(_todayBreaksController.text.trim());
    if (todaySleep != null) appState.setTodaySleep(todaySleep);
    if (todayBreaks != null) appState.setTodayBreaks(todayBreaks);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Сохранено'), duration: Duration(seconds: 1)),
    );
  }
}
