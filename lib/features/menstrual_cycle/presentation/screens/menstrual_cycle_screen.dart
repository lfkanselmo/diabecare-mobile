import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/widgets/buttons/app_primary_button.dart';
import '../../../../shared/widgets/pickers/adaptive_date_picker.dart';
import '../../domain/entities/menstrual_cycle_status.dart';
import '../providers/menstrual_cycle_providers.dart';
import '../widgets/phase_calendar_strip.dart';

class MenstrualCycleScreen extends ConsumerStatefulWidget {
  const MenstrualCycleScreen({super.key});

  @override
  ConsumerState<MenstrualCycleScreen> createState() => _MenstrualCycleScreenState();
}

class _MenstrualCycleScreenState extends ConsumerState<MenstrualCycleScreen> {
  late Future<MenstrualCycleStatus> _statusFuture;

  @override
  void initState() {
    super.initState();
    _statusFuture = ref.read(menstrualCycleRepositoryProvider).getStatus();
  }

  void _refresh() {
    setState(() {
      _statusFuture = ref.read(menstrualCycleRepositoryProvider).getStatus();
    });
  }

  Future<void> _startPeriod() async {
    final l10n = AppLocalizations.of(context)!;
    final date = await showAppDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (date == null || !mounted) return;

    try {
      await ref.read(menstrualCycleRepositoryProvider).registerCycle(startDate: date);
      _refresh();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.cycleErrorMessage)));
      }
    }
  }

  Future<void> _finishPeriod() async {
    final l10n = AppLocalizations.of(context)!;
    final date = await showAppDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (date == null || !mounted) return;

    try {
      await ref.read(menstrualCycleRepositoryProvider).finishPeriod(endDate: date);
      _refresh();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.cycleErrorMessage)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat.yMd(l10n.localeName);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cycleTitle)),
      body: SafeArea(
        child: FutureBuilder<MenstrualCycleStatus>(
          future: _statusFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final status = snapshot.data!;

            return RefreshIndicator(
              onRefresh: () async => _refresh(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const PhaseCalendarStrip(),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(status.currentPhaseLabel, style: Theme.of(context).textTheme.titleLarge),
                          Text(l10n.cycleDayOfCycle(status.dayOfCycle)),
                          const SizedBox(height: 8),
                          Text(status.glucoseGuidance),
                          const SizedBox(height: 8),
                          Text(l10n.cycleNextStart(dateFormat.format(status.nextCycleStart))),
                          if (status.isProjectionStale) ...[
                            const SizedBox(height: 8),
                            Text(
                              l10n.cycleProjectionStale,
                              style: TextStyle(color: Theme.of(context).colorScheme.error),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (status.isOngoing)
                    AppPrimaryButton(label: l10n.cycleFinishPeriod, onPressed: _finishPeriod)
                  else
                    AppPrimaryButton(label: l10n.cycleStartPeriod, onPressed: _startPeriod),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () async {
                      await context.push('/cycle/log');
                      _refresh();
                    },
                    child: Text(l10n.cycleLogToday),
                  ),
                  const SizedBox(height: 24),
                  Text(l10n.cycleHistoryTitle, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (status.history.isEmpty) Text(l10n.cycleHistoryEmpty),
                  for (final item in status.history)
                    ListTile(
                      title: Text(dateFormat.format(item.startDate)),
                      subtitle: Text(
                        item.endDate == null
                            ? l10n.cycleOngoing
                            : '${dateFormat.format(item.endDate!)} (${item.actualPeriodLengthDays ?? '—'} ${l10n.cycleDaysSuffix})',
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
