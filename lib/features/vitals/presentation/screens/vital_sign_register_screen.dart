import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/widgets/buttons/app_primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/pickers/adaptive_date_picker.dart';
import '../providers/vitals_providers.dart';

/// Sin validación de rangos client-side — todos los campos son opcionales,
/// igual que `RegisterVitalSignRequest` del backend (no se inventan rangos
/// que el backend no exige, ver plan de Fase 2).
class VitalSignRegisterScreen extends ConsumerStatefulWidget {
  const VitalSignRegisterScreen({super.key});

  @override
  ConsumerState<VitalSignRegisterScreen> createState() => _VitalSignRegisterScreenState();
}

class _VitalSignRegisterScreenState extends ConsumerState<VitalSignRegisterScreen> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _hba1cController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _measuredAt = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _heartRateController.dispose();
    _hba1cController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickMeasuredAt() async {
    final date = await showAppDatePicker(
      context: context,
      initialDate: _measuredAt,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_measuredAt));
    if (time == null) return;

    setState(() {
      _measuredAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSaving = true);
    try {
      await ref
          .read(vitalSignRepositoryProvider)
          .register(
            weightKg: double.tryParse(_weightController.text),
            heightCm: double.tryParse(_heightController.text),
            systolicBp: int.tryParse(_systolicController.text),
            diastolicBp: int.tryParse(_diastolicController.text),
            heartRate: int.tryParse(_heartRateController.text),
            hba1c: double.tryParse(_hba1cController.text),
            measuredAt: _measuredAt,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.vitalsSuccessMessage)));
        context.go('/vitals');
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.vitalsErrorMessage)));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.vitalsRegisterTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: l10n.vitalsWeight,
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l10n.vitalsHeight,
                controller: _heightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: l10n.vitalsSystolic,
                      controller: _systolicController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: l10n.vitalsDiastolic,
                      controller: _diastolicController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l10n.vitalsHeartRate,
                controller: _heartRateController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l10n.vitalsHba1c,
                controller: _hba1cController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickMeasuredAt,
                child: InputDecorator(
                  decoration: InputDecoration(labelText: l10n.vitalsMeasuredAt),
                  child: Text(DateFormat.yMd(l10n.localeName).add_Hm().format(_measuredAt)),
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(label: l10n.vitalsNotes, controller: _notesController),
              const SizedBox(height: 24),
              AppPrimaryButton(
                label: _isSaving ? l10n.vitalsSaving : l10n.vitalsSave,
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
