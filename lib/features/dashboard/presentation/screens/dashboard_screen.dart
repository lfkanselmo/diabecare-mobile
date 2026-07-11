import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/security/biometric_lock_gate.dart';
import '../../../alerts/presentation/providers/alerts_provider.dart';
import '../../../alerts/presentation/widgets/alerts_panel.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../glucose/presentation/providers/glucose_providers.dart';
import '../../../glucose/presentation/widgets/glucose_stats_card.dart';

/// Dashboard de Fase 1 — muestra solo lo que Fase 1 construye (glucosa +
/// alertas). El resto de tarjetas/accesos rápidos de la web (nutrición,
/// vitales, ciclo) se agregan cuando esos dominios lleguen (Fase 2/3), no
/// se construyen accesos a pantallas que todavía no existen.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(authProvider).value;
    final alertsAsync = ref.watch(alertsProvider);

    final to = DateTime.now();
    final from = to.subtract(const Duration(days: 7));
    final statsAsync = ref.watch(glucoseStatsProvider(from: from, to: to));

    return BiometricLockGate(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.dashboardTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => ref.read(authProvider.notifier).logout(),
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
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => context.push('/glucose/register'),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.dashboardRegisterGlucose),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
