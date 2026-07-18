import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/l10n/enum_labels.dart';
import '../../../../shared/widgets/buttons/app_primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../domain/entities/cycle_symptom.dart';
import '../../domain/entities/flow_intensity.dart';
import '../../domain/entities/symptom_severity.dart';
import '../../domain/repositories/menstrual_cycle_repository.dart';
import '../providers/menstrual_cycle_providers.dart';

/// Cada síntoma tiene 4 estados por tap: sin seleccionar → leve → moderado →
/// severo → sin seleccionar — evita un diálogo extra por síntoma para un
/// formulario que ya maneja 27 opciones.
class CycleDayEntryScreen extends ConsumerStatefulWidget {
  const CycleDayEntryScreen({super.key});

  @override
  ConsumerState<CycleDayEntryScreen> createState() => _CycleDayEntryScreenState();
}

class _CycleDayEntryScreenState extends ConsumerState<CycleDayEntryScreen> {
  final _notesController = TextEditingController();
  FlowIntensity _flowIntensity = FlowIntensity.none;
  final Map<CycleSymptom, SymptomSeverity> _symptoms = {};
  bool _isSaving = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _cycleSeverity(CycleSymptom symptom) {
    setState(() {
      final current = _symptoms[symptom];
      if (current == null) {
        _symptoms[symptom] = SymptomSeverity.mild;
      } else if (current == SymptomSeverity.mild) {
        _symptoms[symptom] = SymptomSeverity.moderate;
      } else if (current == SymptomSeverity.moderate) {
        _symptoms[symptom] = SymptomSeverity.severe;
      } else {
        _symptoms.remove(symptom);
      }
    });
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSaving = true);
    try {
      await ref
          .read(menstrualCycleRepositoryProvider)
          .registerDayEntry(
            entryDate: DateTime.now(),
            flowIntensity: _flowIntensity,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
            symptoms: [
              for (final entry in _symptoms.entries) SymptomInput(symptom: entry.key, severity: entry.value),
            ],
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.cycleDayEntrySuccessMessage)));
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.cycleDayEntryErrorMessage)));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Color? _chipColor(BuildContext context, SymptomSeverity? severity) {
    final scheme = Theme.of(context).colorScheme;
    return switch (severity) {
      null => null,
      SymptomSeverity.mild => scheme.primaryContainer,
      SymptomSeverity.moderate => scheme.tertiaryContainer,
      SymptomSeverity.severe => scheme.errorContainer,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cycleDayEntryTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<FlowIntensity>(
                initialValue: _flowIntensity,
                decoration: InputDecoration(labelText: l10n.cycleDayEntryFlowIntensity),
                items: FlowIntensity.values
                    .map((f) => DropdownMenuItem(value: f, child: Text(f.label(l10n))))
                    .toList(),
                onChanged: (value) => setState(() => _flowIntensity = value!),
              ),
              const SizedBox(height: 16),
              Text(l10n.cycleDayEntrySymptoms, style: Theme.of(context).textTheme.labelLarge),
              Text(l10n.cycleDayEntrySymptomsHint, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final symptom in CycleSymptom.values)
                    FilterChip(
                      label: Text(symptom.label(l10n)),
                      selected: _symptoms.containsKey(symptom),
                      backgroundColor: _chipColor(context, _symptoms[symptom]),
                      selectedColor: _chipColor(context, _symptoms[symptom]),
                      onSelected: (_) => _cycleSeverity(symptom),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              AppTextField(label: l10n.cycleDayEntryNotes, controller: _notesController),
              const SizedBox(height: 24),
              AppPrimaryButton(
                label: _isSaving ? l10n.cycleDayEntrySaving : l10n.cycleDayEntrySave,
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
