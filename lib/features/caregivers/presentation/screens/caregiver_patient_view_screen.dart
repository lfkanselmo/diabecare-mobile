import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../shared/l10n/enum_labels.dart';
import '../../../alerts/domain/entities/alert.dart';
import '../../../alerts/presentation/widgets/alerts_panel.dart';
import '../../../auth/domain/entities/patient.dart';
import '../../../glucose/domain/entities/glucose_stats.dart';
import '../../../glucose/presentation/providers/glucose_providers.dart';
import '../../../glucose/presentation/widgets/glucose_stats_card.dart';

class _CaregiverPatientSnapshot {
  const _CaregiverPatientSnapshot({required this.patient, required this.stats, required this.alerts});

  final Patient patient;
  final GlucoseStats? stats;
  final List<Alert> alerts;
}

/// Vista de solo lectura para un cuidador — mismo alcance que
/// `caregiver-view.component.ts` de la web: info del paciente, estadísticas
/// de los últimos 14 días y alertas. No es un espejo completo de la app
/// (nutrición/vitales/etc. no tienen vista de cuidador, ni en la web).
class CaregiverPatientViewScreen extends ConsumerWidget {
  const CaregiverPatientViewScreen({super.key, required this.patientId});

  final String patientId;

  Future<_CaregiverPatientSnapshot> _load(WidgetRef ref) async {
    final dio = ref.read(apiDioProvider);
    final glucoseApiClient = ref.read(glucoseApiClientProvider);

    final to = DateTime.now();
    final from = to.subtract(const Duration(days: 14));

    final patientFuture = dio.get<Map<String, dynamic>>('/patients/$patientId');
    final statsFuture = glucoseApiClient
        .getStats(patientId: patientId, from: from, to: to)
        .then<GlucoseStats?>(
          (dto) => GlucoseStats(
            average: dto.average,
            standardDeviation: dto.standardDeviation,
            coefficientOfVariation: dto.coefficientOfVariation,
            estimatedHba1c: dto.estimatedHba1c,
            timeInRangePercent: dto.timeInRangePercent,
            timeBelowRangePercent: dto.timeBelowRangePercent,
            timeAboveRangePercent: dto.timeAboveRangePercent,
            totalReadings: dto.totalReadings,
          ),
        )
        .catchError((_) => null);
    final alertsFuture = dio
        .get<List<dynamic>>('/alerts/$patientId')
        .then((response) => response.data!.map((e) => Alert.fromJson(e as Map<String, dynamic>)).toList())
        .catchError((_) => <Alert>[]);

    final patientResponse = await patientFuture;
    final stats = await statsFuture;
    final alerts = await alertsFuture;

    return _CaregiverPatientSnapshot(
      patient: Patient.fromJson(patientResponse.data!),
      stats: stats,
      alerts: alerts,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.caregiverPatientViewTitle)),
      body: SafeArea(
        child: FutureBuilder<_CaregiverPatientSnapshot>(
          future: _load(ref),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final data = snapshot.data!;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(data.patient.fullName, style: Theme.of(context).textTheme.titleLarge),
                Text(data.patient.diabetesType.label(l10n)),
                const SizedBox(height: 16),
                AlertsPanel(alerts: data.alerts),
                const SizedBox(height: 16),
                if (data.stats != null) GlucoseStatsCard(stats: data.stats!),
              ],
            );
          },
        ),
      ),
    );
  }
}
