import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/l10n/enum_labels.dart';
import '../../../../shared/widgets/dialogs/confirm_dialog.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/glucose_reading.dart';
import '../providers/glucose_providers.dart';
import '../widgets/glucose_chart.dart';

enum _HistoryView { chart, table }

class GlucoseHistoryScreen extends ConsumerStatefulWidget {
  const GlucoseHistoryScreen({super.key});

  @override
  ConsumerState<GlucoseHistoryScreen> createState() => _GlucoseHistoryScreenState();
}

class _GlucoseHistoryScreenState extends ConsumerState<GlucoseHistoryScreen> {
  late DateTime _from;
  late DateTime _to;
  _HistoryView _view = _HistoryView.chart;

  @override
  void initState() {
    super.initState();
    _to = DateTime.now();
    _from = _to.subtract(const Duration(days: 30));
  }

  void _applyQuickRange(int days) {
    setState(() {
      _to = DateTime.now();
      _from = _to.subtract(Duration(days: days));
    });
  }

  Future<void> _delete(GlucoseReading reading) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showAdaptiveConfirmDialog(
      context: context,
      title: l10n.glucoseHistoryTitle,
      message: l10n.glucoseHistoryConfirmDeleteQuestion,
      confirmLabel: l10n.commonDelete,
      cancelLabel: l10n.commonCancel,
      isDestructive: true,
    );
    if (!confirmed) return;
    await ref.read(glucoseRepositoryProvider).delete(reading.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final patient = ref.watch(authProvider).value?.patient;
    final targetMin = patient?.targetGlucoseMin ?? 70;
    final targetMax = patient?.targetGlucoseMax ?? 180;
    final readingsAsync = ref.watch(glucoseReadingsProvider(from: _from, to: _to));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.glucoseHistoryTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.dashboardRegisterGlucose,
            onPressed: () => context.push('/glucose/register'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(l10n.glucoseHistoryLast7Days),
                    selected: false,
                    onSelected: (_) => _applyQuickRange(7),
                  ),
                  ChoiceChip(
                    label: Text(l10n.glucoseHistoryLast30Days),
                    selected: false,
                    onSelected: (_) => _applyQuickRange(30),
                  ),
                  ChoiceChip(
                    label: Text(l10n.glucoseHistoryLast90Days),
                    selected: false,
                    onSelected: (_) => _applyQuickRange(90),
                  ),
                  ChoiceChip(
                    label: Text(l10n.glucoseHistoryLast6Months),
                    selected: false,
                    onSelected: (_) => _applyQuickRange(180),
                  ),
                ],
              ),
            ),
            SegmentedButton<_HistoryView>(
              segments: [
                ButtonSegment(value: _HistoryView.chart, label: Text(l10n.glucoseHistoryChart)),
                ButtonSegment(value: _HistoryView.table, label: Text(l10n.glucoseHistoryTable)),
              ],
              selected: {_view},
              onSelectionChanged: (values) => setState(() => _view = values.first),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: readingsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('$error')),
                data: (readings) {
                  if (readings.isEmpty) {
                    return Center(
                      child: TextButton(
                        onPressed: () => context.push('/glucose/register'),
                        child: Text(l10n.glucoseHistoryRegisterFirst),
                      ),
                    );
                  }

                  if (_view == _HistoryView.chart) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: GlucoseChart(readings: readings, from: _from, targetMin: targetMin, targetMax: targetMax),
                    );
                  }

                  final dateFormat = DateFormat.yMd(l10n.localeName).add_Hm();
                  return ListView.builder(
                    itemCount: readings.length,
                    itemBuilder: (context, index) {
                      final reading = readings[index];
                      return ListTile(
                        title: Text('${reading.value} ${reading.unit.label(l10n)}'),
                        subtitle: Text('${reading.readingType.label(l10n)} · ${dateFormat.format(reading.measuredAt)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: l10n.commonDelete,
                          onPressed: () => _delete(reading),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
