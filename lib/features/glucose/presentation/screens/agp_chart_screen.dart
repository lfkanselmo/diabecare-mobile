import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/glucose_providers.dart';
import '../widgets/agp_chart.dart';

class AgpChartScreen extends ConsumerStatefulWidget {
  const AgpChartScreen({super.key});

  @override
  ConsumerState<AgpChartScreen> createState() => _AgpChartScreenState();
}

class _AgpChartScreenState extends ConsumerState<AgpChartScreen> {
  // Fijado una sola vez al entrar a la pantalla — ver comentario equivalente
  // en dashboard_screen.dart: recalcular DateTime.now() en cada build()
  // rompe el caché del provider family y dispara una llamada de red nueva
  // en cada rebuild.
  late final DateTime _to = DateTime.now();
  late final DateTime _from = _to.subtract(const Duration(days: 90));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final patient = ref.watch(authProvider).value?.patient;
    final targetMin = patient?.targetGlucoseMin ?? 70;
    final targetMax = patient?.targetGlucoseMax ?? 180;

    final agpAsync = ref.watch(glucoseAgpProfileProvider(from: _from, to: _to));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.glucoseHistoryTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: agpAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('$error')),
            data: (buckets) => AgpChart(buckets: buckets, targetMin: targetMin, targetMax: targetMax),
          ),
        ),
      ),
    );
  }
}
