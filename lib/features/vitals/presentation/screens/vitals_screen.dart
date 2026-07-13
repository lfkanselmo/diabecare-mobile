import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../domain/entities/exercise_log.dart';
import '../../domain/entities/hba1c_trend_point.dart';
import '../../domain/entities/vital_sign.dart';
import '../providers/vitals_providers.dart';
import '../widgets/hba1c_trend_chart.dart';

/// Historial combinado de vitales + ejercicio con tabs — igual estructura
/// que `vitals.component.ts` de la web.
class VitalsScreen extends ConsumerStatefulWidget {
  const VitalsScreen({super.key});

  @override
  ConsumerState<VitalsScreen> createState() => _VitalsScreenState();
}

class _VitalsScreenState extends ConsumerState<VitalsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 90));
    final to = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.vitalsHistoryTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.vitalsTabVitals),
            Tab(text: l10n.vitalsTabExercise),
            Tab(text: l10n.vitalsTabHba1cTrend),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _VitalsList(from: from, to: to),
          _ExerciseList(from: from, to: to),
          const _Hba1cTrendTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final destination = _tabController.index == 1 ? '/exercise/register' : '/vitals/register';
          context.push(destination);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _VitalsList extends ConsumerWidget {
  const _VitalsList({required this.from, required this.to});

  final DateTime from;
  final DateTime to;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final vitalsAsync = ref.watch(vitalsByRangeProvider(from: from, to: to));

    return vitalsAsync.when(
      data: (vitals) => vitals.isEmpty
          ? Center(child: Text(l10n.vitalsHistoryEmpty))
          : ListView.builder(
              itemCount: vitals.length,
              itemBuilder: (context, index) => _VitalTile(vital: vitals[index]),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(child: Text(l10n.vitalsErrorMessage)),
    );
  }
}

class _VitalTile extends StatelessWidget {
  const _VitalTile({required this.vital});

  final VitalSign vital;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat.yMd(l10n.localeName).add_Hm();
    final parts = <String>[
      if (vital.weightKg != null) '${vital.weightKg} kg',
      if (vital.systolicBp != null && vital.diastolicBp != null) '${vital.systolicBp}/${vital.diastolicBp} mmHg',
      if (vital.heartRate != null) '${vital.heartRate} bpm',
      if (vital.hba1c != null) 'HbA1c ${vital.hba1c}%',
    ];
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(parts.isEmpty ? '—' : parts.join(' · ')),
        subtitle: Text(dateFormat.format(vital.measuredAt)),
        trailing: vital.bmi == null ? null : Text('BMI ${vital.bmi}'),
      ),
    );
  }
}

class _ExerciseList extends ConsumerWidget {
  const _ExerciseList({required this.from, required this.to});

  final DateTime from;
  final DateTime to;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final logsAsync = ref.watch(exerciseLogsByRangeProvider(from: from, to: to));

    return logsAsync.when(
      data: (logs) => logs.isEmpty
          ? Center(child: Text(l10n.exerciseHistoryEmpty))
          : ListView.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) => _ExerciseTile(log: logs[index]),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(child: Text(l10n.exerciseErrorMessage)),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({required this.log});

  final ExerciseLog log;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat.yMd(l10n.localeName).add_Hm();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text('${log.exerciseType.wireValue} · ${log.durationMinutes} min'),
        subtitle: Text(dateFormat.format(log.performedAt)),
        trailing: log.caloriesBurned == null
            ? Icon(Icons.sync, color: Theme.of(context).colorScheme.outline)
            : Text('${log.caloriesBurned!.toStringAsFixed(0)} kcal'),
      ),
    );
  }
}

class _Hba1cTrendTab extends ConsumerWidget {
  const _Hba1cTrendTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<List<Hba1cTrendPoint>>(
      future: ref.read(vitalSignRepositoryProvider).getHba1cTrend(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text(l10n.vitalsHba1cTrendErrorMessage));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final points = snapshot.data!;
        if (points.isEmpty) return Center(child: Text(l10n.vitalsHba1cTrendEmpty));
        return Padding(padding: const EdgeInsets.all(16), child: Hba1cTrendChart(points: points));
      },
    );
  }
}
