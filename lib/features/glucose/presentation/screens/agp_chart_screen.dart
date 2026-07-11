import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/glucose_providers.dart';
import '../widgets/agp_chart.dart';

class AgpChartScreen extends ConsumerWidget {
  const AgpChartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final patient = ref.watch(authProvider).value?.patient;
    final targetMin = patient?.targetGlucoseMin ?? 70;
    final targetMax = patient?.targetGlucoseMax ?? 180;

    final to = DateTime.now();
    final from = to.subtract(const Duration(days: 90));
    final agpAsync = ref.watch(glucoseAgpProfileProvider(from: from, to: to));

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
