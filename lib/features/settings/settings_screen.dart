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
      text: today.sleepHours?.toString() ?? '',
    );
    _todayWorkController = TextEditingController(
      text: today.breaksCount.toString(),
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
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingM),
                children: [
                  _niceField(context, 'Спал', _todaySleepController, hint: 'часов', icon: Icons.bed_rounded),
                  const SizedBox(height: spacingM),
                  _niceField(context, 'Работал', _todayWorkController, hint: 'часов', icon: Icons.schedule_rounded),
                  const SizedBox(height: spacingXl),
                  FilledButton(
                    onPressed: () => _saveAll(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: spacingM),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusButton)),
                    ),
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

  Widget _niceField(BuildContext context, String label, TextEditingController c, {String hint = '', required IconData icon}) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radiusCard),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.3), width: 1),
      ),
      child: TextField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 22, color: scheme.onSurfaceVariant),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingM),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
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
    if (todayBreaks != null) appState.setTodayBreaks(todayBreaks);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Сохранено'), duration: Duration(seconds: 1)),
    );
  }
}
