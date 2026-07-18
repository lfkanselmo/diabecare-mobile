import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/l10n/enum_labels.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/buttons/app_primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/pickers/adaptive_date_picker.dart';
import '../../../../shared/widgets/pickers/adaptive_segmented_control.dart';
import '../../../alerts/presentation/providers/alerts_provider.dart';
import '../../domain/entities/glucose_unit.dart';
import '../../domain/entities/reading_type.dart';
import '../providers/glucose_providers.dart';

class GlucoseRegisterScreen extends ConsumerStatefulWidget {
  const GlucoseRegisterScreen({super.key});

  @override
  ConsumerState<GlucoseRegisterScreen> createState() => _GlucoseRegisterScreenState();
}

class _GlucoseRegisterScreenState extends ConsumerState<GlucoseRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _notesController = TextEditingController();
  final _deviceSourceController = TextEditingController();

  GlucoseUnit _unit = GlucoseUnit.mgDl;
  ReadingType? _readingType;
  DateTime _measuredAt = DateTime.now();
  bool _isSaving = false;
  bool _isConnectingMeter = false;

  @override
  void dispose() {
    _valueController.dispose();
    _notesController.dispose();
    _deviceSourceController.dispose();
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

  Future<void> _connectMeter() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isConnectingMeter = true);
    try {
      final measurement = await ref.read(bleGlucoseMeterServiceProvider).readLatestMeasurement();
      setState(() {
        _valueController.text = measurement.value.toString();
        _unit = measurement.unit;
        _measuredAt = measurement.measuredAt;
        _deviceSourceController.text = measurement.deviceName;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.glucoseRegisterMeterConnectedSuccess(measurement.deviceName))),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.glucoseRegisterMeterConnectError)));
      }
    } finally {
      if (mounted) setState(() => _isConnectingMeter = false);
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!(_formKey.currentState?.validate() ?? false) || _readingType == null) return;

    setState(() => _isSaving = true);
    try {
      await ref
          .read(glucoseRepositoryProvider)
          .register(
            value: double.parse(_valueController.text),
            unit: _unit,
            readingType: _readingType!,
            measuredAt: _measuredAt,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
            deviceSource: _deviceSourceController.text.isEmpty ? null : _deviceSourceController.text,
          );

      // Igual que `glucose-register.component.ts`: refresca alertas antes de
      // navegar, sin bloquear la navegación si falla.
      unawaited(ref.read(alertsProvider.notifier).refresh());

      if (mounted) {
        unawaited(HapticFeedback.mediumImpact());
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.glucoseRegisterSuccessMessage)));
        context.go('/glucose/history');
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.glucoseRegisterErrorMessage)));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.glucoseRegisterTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AsyncValueView<bool>.future(
                  future: ref.read(bleGlucoseMeterServiceProvider).isSupported(),
                  errorMessage: l10n.glucoseRegisterMeterUnsupported,
                  builder: (context, supported) {
                    if (!supported) {
                      return Text(l10n.glucoseRegisterMeterUnsupported);
                    }
                    return OutlinedButton.icon(
                      onPressed: _isConnectingMeter ? null : _connectMeter,
                      icon: const Icon(Icons.bluetooth),
                      label: Text(
                        _isConnectingMeter ? l10n.glucoseRegisterConnectingMeter : l10n.glucoseRegisterConnectMeter,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: l10n.glucoseRegisterValue,
                  controller: _valueController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    final parsed = double.tryParse(value ?? '');
                    if (parsed == null) return l10n.glucoseRegisterValueRequired;
                    if (parsed < 20 || parsed > 600) return l10n.glucoseRegisterValueRange;
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(l10n.glucoseRegisterUnit, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                AdaptiveSegmentedControl<GlucoseUnit>(
                  options: const {GlucoseUnit.mgDl: 'mg/dL', GlucoseUnit.mmolL: 'mmol/L'},
                  selected: _unit,
                  onChanged: (value) => setState(() => _unit = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ReadingType>(
                  initialValue: _readingType,
                  decoration: InputDecoration(labelText: l10n.glucoseRegisterReadingType),
                  items: ReadingType.values
                      .map((type) => DropdownMenuItem(value: type, child: Text(type.label(l10n))))
                      .toList(),
                  onChanged: (value) => setState(() => _readingType = value),
                  validator: (value) => value == null ? l10n.glucoseRegisterReadingTypeRequired : null,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _pickMeasuredAt,
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: l10n.glucoseRegisterDateTime),
                    child: Text(DateFormat.yMd(l10n.localeName).add_Hm().format(_measuredAt)),
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(label: l10n.glucoseRegisterNotes, controller: _notesController),
                const SizedBox(height: 16),
                AppTextField(
                  label: l10n.glucoseRegisterDeviceSource,
                  controller: _deviceSourceController,
                ),
                const SizedBox(height: 24),
                AppPrimaryButton(
                  label: _isSaving ? l10n.glucoseRegisterSaving : l10n.glucoseRegisterSave,
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
