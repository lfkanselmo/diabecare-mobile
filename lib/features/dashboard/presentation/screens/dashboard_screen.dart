import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/security/biometric_lock_gate.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../alerts/presentation/providers/alerts_provider.dart';
import '../../../alerts/presentation/widgets/alerts_panel.dart';
import '../../../auth/domain/entities/biological_sex.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../glucose/presentation/providers/glucose_providers.dart';
import '../../../glucose/presentation/widgets/glucose_stats_card.dart';
import '../../../nutrition/presentation/widgets/daily_summary_card.dart';
import '../../../vitals/presentation/providers/vitals_providers.dart';

/// Dashboard de Fase 1 + Fase 2 + Fase 3 — glucosa, alertas, resumen diario
/// de nutrición, último signo vital y acceso rápido al ciclo menstrual
/// (solo si `biologicalSex == FEMALE`, mismo gate que `dashboard.component.ts`).
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  // Fijado una sola vez al entrar a la pantalla: recalcular DateTime.now() en
  // cada build() rompía tanto el caché del provider family como el TTL de
  // GlucoseStatsCache (la key incluye from/to con microsegundos), disparando
  // una llamada de red nueva en cada rebuild del dashboard.
  late final DateTime _to = DateTime.now();
  late final DateTime _from = _to.subtract(const Duration(days: 7));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(authProvider).value;
    final alertsAsync = ref.watch(alertsProvider);

    final statsAsync = ref.watch(glucoseStatsProvider(from: _from, to: _to));

    return BiometricLockGate(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.dashboardTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_outline),
              tooltip: l10n.profileTitle,
              onPressed: () => context.push('/profile'),
            ),
          ],
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => ref.read(alertsProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (session?.patient != null)
                  Text(session!.patient!.fullName, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                alertsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (error, stack) => const SizedBox.shrink(),
                  data: (alerts) => AlertsPanel(alerts: alerts),
                ),
                statsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => TextButton(
                    onPressed: () => context.push('/glucose/register'),
                    child: Text(l10n.dashboardNoReadingsYet),
                  ),
                  data: (stats) => stats.totalReadings == 0
                      ? TextButton(
                          onPressed: () => context.push('/glucose/register'),
                          child: Text(l10n.dashboardNoReadingsYet),
                        )
                      : GlucoseStatsCard(stats: stats),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.push('/glucose/history'),
                  child: Text(l10n.dashboardViewHistory),
                ),
                const SizedBox(height: 16),
                const DailySummaryCard(),
                const SizedBox(height: 16),
                const _LatestVitalCard(),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => context.push('/glucose/register'),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.dashboardRegisterGlucose),
                ),
                const SizedBox(height: 8),
                FilledButton.tonalIcon(
                  onPressed: () => context.push('/nutrition/log'),
                  icon: const Icon(Icons.restaurant),
                  label: Text(l10n.dashboardRegisterMeal),
                ),
                const SizedBox(height: 8),
                FilledButton.tonalIcon(
                  onPressed: () => context.push('/vitals'),
                  icon: const Icon(Icons.monitor_heart_outlined),
                  label: Text(l10n.dashboardVitals),
                ),
                const SizedBox(height: 8),
                FilledButton.tonalIcon(
                  onPressed: () => context.push('/medications'),
                  icon: const Icon(Icons.medication_outlined),
                  label: Text(l10n.dashboardMedications),
                ),
                if (session?.patient?.biologicalSex == BiologicalSex.female) ...[
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    onPressed: () => context.push('/cycle'),
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text(l10n.dashboardCycle),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LatestVitalCard extends ConsumerWidget {
  const _LatestVitalCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return AsyncValueView.future(
      future: ref.read(vitalSignRepositoryProvider).getLatest(),
      errorMessage: l10n.commonSomethingWentWrong,
      builder: (context, vital) {
        if (vital == null) return const SizedBox.shrink();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.dashboardLatestVitalTitle, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (vital.weightKg != null) Text('${l10n.vitalsWeight}: ${vital.weightKg} kg'),
                if (vital.bmi != null) Text('BMI: ${vital.bmi}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
