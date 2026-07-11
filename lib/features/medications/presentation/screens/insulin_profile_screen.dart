import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/widgets/buttons/app_primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/medication_providers.dart';

/// Sin GET dedicado — los valores actuales vienen de `PatientResponse`, ya
/// disponible en la sesión de auth (ver plan de Fase 2).
class InsulinProfileScreen extends ConsumerStatefulWidget {
  const InsulinProfileScreen({super.key});

  @override
  ConsumerState<InsulinProfileScreen> createState() => _InsulinProfileScreenState();
}

class _InsulinProfileScreenState extends ConsumerState<InsulinProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _sensitivityController;
  late final TextEditingController _carbRatioController;
  late final TextEditingController _targetGlucoseController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final patient = ref.read(authProvider).value?.patient;
    _sensitivityController = TextEditingController(text: patient?.insulinSensitivityFactor?.toString() ?? '');
    _carbRatioController = TextEditingController(text: patient?.insulinToCarbRatio?.toString() ?? '');
    _targetGlucoseController = TextEditingController(text: patient?.targetGlucoseForCorrection?.toString() ?? '');
  }

  @override
  void dispose() {
    _sensitivityController.dispose();
    _carbRatioController.dispose();
    _targetGlucoseController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      await ref
          .read(medicationRepositoryProvider)
          .updateInsulinProfile(
            sensitivityFactor: double.parse(_sensitivityController.text),
            carbRatio: double.parse(_carbRatioController.text),
            targetGlucose: double.parse(_targetGlucoseController.text),
          );
      ref.invalidate(authProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.medicationsSuccessMessage)));
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.medicationsErrorMessage)));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _positiveNumberValidator(String? value) {
    final parsed = double.tryParse(value ?? '');
    return (parsed == null || parsed <= 0) ? AppLocalizations.of(context)!.medicationsInsulinProfileFieldRequired : null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.medicationsInsulinProfileTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.medicationsInsulinProfileDescription),
                const SizedBox(height: 24),
                AppTextField(
                  label: l10n.medicationsInsulinProfileSensitivity,
                  controller: _sensitivityController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: _positiveNumberValidator,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: l10n.medicationsInsulinProfileCarbRatio,
                  controller: _carbRatioController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: _positiveNumberValidator,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: l10n.medicationsInsulinProfileTargetGlucose,
                  controller: _targetGlucoseController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: _positiveNumberValidator,
                ),
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
