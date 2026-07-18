import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/l10n/enum_labels.dart';
import '../../../../shared/widgets/buttons/app_primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/pickers/adaptive_date_picker.dart';
import '../../domain/entities/dose_unit.dart';
import '../../domain/entities/medication_frequency.dart';
import '../../domain/entities/medication_type.dart';
import '../providers/medication_providers.dart';

class MedicationRegisterScreen extends ConsumerStatefulWidget {
  const MedicationRegisterScreen({super.key});

  @override
  ConsumerState<MedicationRegisterScreen> createState() => _MedicationRegisterScreenState();
}

class _MedicationRegisterScreenState extends ConsumerState<MedicationRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _doseController = TextEditingController();
  final _notesController = TextEditingController();

  MedicationType _type = MedicationType.oral;
  DoseUnit _doseUnit = DoseUnit.mg;
  MedicationFrequency _frequency = MedicationFrequency.onceDaily;
  DateTime? _startDate;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final date = await showAppDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 3650)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _startDate = date);
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      await ref
          .read(medicationRepositoryProvider)
          .register(
            name: _nameController.text,
            type: _type,
            dose: double.parse(_doseController.text),
            doseUnit: _doseUnit,
            frequency: _frequency,
            startDate: _startDate,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.medicationsSuccessMessage)));
        context.go('/medications');
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.medicationsErrorMessage)));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.medicationsRegisterTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: l10n.medicationsName,
                  controller: _nameController,
                  validator: (value) => (value == null || value.isEmpty) ? l10n.medicationsNameRequired : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<MedicationType>(
                  initialValue: _type,
                  decoration: InputDecoration(labelText: l10n.medicationsType),
                  items: MedicationType.values
                      .map((t) => DropdownMenuItem(value: t, child: Text(t.label(l10n))))
                      .toList(),
                  onChanged: (value) => setState(() => _type = value!),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: l10n.medicationsDose,
                        controller: _doseController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          final parsed = double.tryParse(value ?? '');
                          if (parsed == null || parsed <= 0) return l10n.medicationsDoseRequired;
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<DoseUnit>(
                        initialValue: _doseUnit,
                        decoration: InputDecoration(labelText: l10n.medicationsDoseUnit),
                        items: DoseUnit.values
                            .map((u) => DropdownMenuItem(value: u, child: Text(u.label(l10n))))
                            .toList(),
                        onChanged: (value) => setState(() => _doseUnit = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<MedicationFrequency>(
                  initialValue: _frequency,
                  decoration: InputDecoration(labelText: l10n.medicationsFrequency),
                  items: MedicationFrequency.values
                      .map((f) => DropdownMenuItem(value: f, child: Text(f.label(l10n))))
                      .toList(),
                  onChanged: (value) => setState(() => _frequency = value!),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _pickStartDate,
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: l10n.medicationsStartDate),
                    child: Text(_startDate?.toString() ?? '—'),
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(label: l10n.medicationsNotes, controller: _notesController),
                const SizedBox(height: 24),
                AppPrimaryButton(
                  label: _isSaving ? l10n.medicationsSaving : l10n.medicationsSave,
                  isLoading: _isSaving,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
