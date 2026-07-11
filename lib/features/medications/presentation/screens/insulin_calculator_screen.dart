import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/network/api_error.dart';
import '../../../../shared/widgets/buttons/app_primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../domain/entities/insulin_calculation_result.dart';
import '../providers/medication_providers.dart';

/// Aviso educativo estático siempre visible, además del `disclaimer` que
/// devuelve el backend — todo el cálculo es del servidor (ver plan de Fase 2).
class InsulinCalculatorScreen extends ConsumerStatefulWidget {
  const InsulinCalculatorScreen({super.key});

  @override
  ConsumerState<InsulinCalculatorScreen> createState() => _InsulinCalculatorScreenState();
}

class _InsulinCalculatorScreenState extends ConsumerState<InsulinCalculatorScreen> {
  final _glucoseController = TextEditingController();
  final _carbsController = TextEditingController();
  bool _beforeMeal = true;
  bool _isCalculating = false;
  InsulinCalculationResult? _result;

  @override
  void dispose() {
    _glucoseController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  Future<void> _calculate() async {
    final l10n = AppLocalizations.of(context)!;
    final glucose = double.tryParse(_glucoseController.text);
    if (glucose == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.medicationsInsulinCalculatorGlucoseRequired)));
      return;
    }

    setState(() {
      _isCalculating = true;
      _result = null;
    });
    try {
      final result = await ref
          .read(medicationRepositoryProvider)
          .calculateInsulinDose(
            currentGlucose: glucose,
            carbsToEat: double.tryParse(_carbsController.text),
            beforeMeal: _beforeMeal,
          );
      if (mounted) setState(() => _result = result);
    } catch (error) {
      if (!mounted) return;
      if (extractApiErrorCode(error) == 'DOMAIN_VALIDATION_ERROR') {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.medicationsInsulinCalculatorProfileMissing)));
        context.push('/medications/insulin-profile');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.medicationsErrorMessage)));
      }
    } finally {
      if (mounted) setState(() => _isCalculating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.medicationsInsulinCalculatorTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l10n.medicationsInsulinCalculatorEducationalNotice),
                ),
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: l10n.medicationsInsulinCalculatorCurrentGlucose,
                controller: _glucoseController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l10n.medicationsInsulinCalculatorCarbsToEat,
                controller: _carbsController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(l10n.medicationsInsulinCalculatorBeforeMeal),
                value: _beforeMeal,
                onChanged: (value) => setState(() => _beforeMeal = value),
              ),
              const SizedBox(height: 24),
              AppPrimaryButton(
                label: _isCalculating
                    ? l10n.medicationsInsulinCalculatorCalculating
                    : l10n.medicationsInsulinCalculatorCalculate,
                isLoading: _isCalculating,
                onPressed: _calculate,
              ),
              if (_result != null) ...[
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.medicationsInsulinCalculatorTotalDose(_result!.totalDose.toStringAsFixed(1)),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(_result!.explanation),
                        const SizedBox(height: 16),
                        Text(_result!.disclaimer, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
