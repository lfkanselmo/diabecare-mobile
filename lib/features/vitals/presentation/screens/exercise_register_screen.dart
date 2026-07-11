import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/widgets/buttons/app_primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/pickers/adaptive_date_picker.dart';
import '../../domain/entities/exercise_intensity.dart';
import '../../domain/entities/exercise_type.dart';
import '../providers/vitals_providers.dart';

/// El toggle manual/automático solo revela/oculta el campo opcional de
/// calorías — no hay estimación client-side antes de enviar, el valor
/// confirmado llega en la respuesta del backend (ver plan de Fase 2).
class ExerciseRegisterScreen extends ConsumerStatefulWidget {
  const ExerciseRegisterScreen({super.key});

  @override
  ConsumerState<ExerciseRegisterScreen> createState() => _ExerciseRegisterScreenState();
}

class _ExerciseRegisterScreenState extends ConsumerState<ExerciseRegisterScreen> {
  final _durationController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _notesController = TextEditingController();

  ExerciseType _exerciseType = ExerciseType.walking;
  ExerciseIntensity _intensity = ExerciseIntensity.moderate;
  DateTime _performedAt = DateTime.now();
  bool _manualCalories = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _durationController.dispose();
    _caloriesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickPerformedAt() async {
    final date = await showAppDatePicker(
      context: context,
      initialDate: _performedAt,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_performedAt));
    if (time == null) return;

    setState(() {
      _performedAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final duration = int.tryParse(_durationController.text);
    if (duration == null || duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.exerciseDurationRequired)));
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref
          .read(exerciseLogRepositoryProvider)
          .register(
            exerciseType: _exerciseType,
            intensity: _intensity,
            durationMinutes: duration,
            performedAt: _performedAt,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
            caloriesBurnedOverride: _manualCalories ? double.tryParse(_caloriesController.text) : null,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.exerciseSuccessMessage)));
        context.go('/vitals');
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.exerciseErrorMessage)));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.exerciseRegisterTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<ExerciseType>(
                initialValue: _exerciseType,
                decoration: InputDecoration(labelText: l10n.exerciseType),
                items: ExerciseType.values
                    .map((type) => DropdownMenuItem(value: type, child: Text(type.wireValue)))
                    .toList(),
                onChanged: (value) => setState(() => _exerciseType = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ExerciseIntensity>(
                initialValue: _intensity,
                decoration: InputDecoration(labelText: l10n.exerciseIntensity),
                items: ExerciseIntensity.values
                    .map((i) => DropdownMenuItem(value: i, child: Text(i.wireValue)))
                    .toList(),
                onChanged: (value) => setState(() => _intensity = value!),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l10n.exerciseDuration,
                controller: _durationController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickPerformedAt,
                child: InputDecorator(
                  decoration: InputDecoration(labelText: l10n.exercisePerformedAt),
                  child: Text(_performedAt.toString()),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(l10n.exerciseManualCalories),
                value: _manualCalories,
                onChanged: (value) => setState(() => _manualCalories = value),
              ),
              if (_manualCalories) ...[
                const SizedBox(height: 8),
                AppTextField(
                  label: l10n.exerciseCaloriesBurned,
                  controller: _caloriesController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
              const SizedBox(height: 16),
              AppTextField(label: l10n.exerciseNotes, controller: _notesController),
              const SizedBox(height: 24),
              AppPrimaryButton(
                label: _isSaving ? l10n.exerciseSaving : l10n.exerciseSave,
                isLoading: _isSaving,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
