import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../state/app_state.dart';
import 'planner_settings.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final settings = appState.plannerSettings ?? PlannerSettings();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Планировщик нагрузки'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(spacingL),
        child: _PlannerForm(initial: settings, onSave: appState.setPlannerSettings),
      ),
    );
  }
}

class _PlannerForm extends StatefulWidget {
  const _PlannerForm({required this.initial, required this.onSave});

  final PlannerSettings initial;
  final void Function(PlannerSettings) onSave;

  @override
  State<_PlannerForm> createState() => _PlannerFormState();
}

class _PlannerFormState extends State<_PlannerForm> {
  late TextEditingController _workController;
  late TextEditingController _sleepController;
  late TextEditingController _maxPlayController;

  @override
  void initState() {
    super.initState();
    _workController = TextEditingController(
      text: widget.initial.workHoursPerDay?.toString() ?? '',
    );
    _sleepController = TextEditingController(
      text: widget.initial.sleepGoalHours.toString(),
    );
    _maxPlayController = TextEditingController(
      text: widget.initial.maxPlayHoursPerDay.toString(),
    );
  }

  @override
  void dispose() {
    _workController.dispose();
    _sleepController.dispose();
    _maxPlayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Часы учёбы/работы в день (оставь пустым для свободного дня)',
          style: theme.textTheme.labelMedium,
        ),
        const SizedBox(height: spacingXs),
        TextField(
          controller: _workController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'например 8',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusField)),
          ),
        ),
        const SizedBox(height: spacingM),
        Text('Цель по сну (часов)', style: theme.textTheme.labelMedium),
        const SizedBox(height: spacingXs),
        TextField(
          controller: _sleepController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: '7',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusField)),
          ),
        ),
        const SizedBox(height: spacingM),
        Text('Максимальное время игры в день (часов)', style: theme.textTheme.labelMedium),
        const SizedBox(height: spacingXs),
        TextField(
          controller: _maxPlayController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: '3',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusField)),
          ),
        ),
        const SizedBox(height: spacingL),
        FilledButton(
          onPressed: _save,
          child: const Text('Сохранить'),
        ),
      ],
    );
  }

  void _save() {
    final work = double.tryParse(_workController.text.trim());
    final sleep = double.tryParse(_sleepController.text.trim()) ?? 7.0;
    final maxPlay = double.tryParse(_maxPlayController.text.trim()) ?? 3.0;

    widget.onSave(PlannerSettings(
      workHoursPerDay: work,
      sleepGoalHours: sleep,
      maxPlayHoursPerDay: maxPlay,
    ));
    Navigator.pop(context);
  }
}
