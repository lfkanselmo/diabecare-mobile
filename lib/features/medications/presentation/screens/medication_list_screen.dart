import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/widgets/dialogs/confirm_dialog.dart';
import '../../domain/entities/medication.dart';
import '../providers/medication_providers.dart';

class MedicationListScreen extends ConsumerWidget {
  const MedicationListScreen({super.key});

  Future<void> _deactivate(BuildContext context, WidgetRef ref, Medication medication) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showAdaptiveConfirmDialog(
      context: context,
      title: l10n.medicationsDeactivateTitle,
      message: l10n.medicationsDeactivateMessage(medication.name),
      confirmLabel: l10n.medicationsDeactivateConfirm,
      cancelLabel: l10n.medicationsCancel,
      isDestructive: true,
    );
    if (!confirmed) return;
    await ref.read(medicationRepositoryProvider).deactivate(medication.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final medicationsAsync = ref.watch(activeMedicationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.medicationsListTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate_outlined),
            tooltip: l10n.medicationsInsulinCalculatorTitle,
            onPressed: () => context.push('/medications/insulin-calculator'),
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: l10n.medicationsInsulinProfileTitle,
            onPressed: () => context.push('/medications/insulin-profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: medicationsAsync.when(
          data: (medications) => medications.isEmpty
              ? Center(child: Text(l10n.medicationsListEmpty))
              : ListView.builder(
                  itemCount: medications.length,
                  itemBuilder: (context, index) {
                    final medication = medications[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(medication.name),
                        subtitle: Text('${medication.dose} ${medication.doseUnit.wireValue} — ${medication.frequency.wireValue}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => _deactivate(context, ref, medication),
                        ),
                      ),
                    );
                  },
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(child: Text(l10n.medicationsErrorMessage)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/medications/register'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
