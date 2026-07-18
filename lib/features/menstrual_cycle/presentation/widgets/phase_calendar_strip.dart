import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../domain/entities/cycle_phase.dart';
import '../../domain/entities/cycle_phase_day.dart';
import '../providers/menstrual_cycle_providers.dart';

/// Franja horizontal de 14 días (7 atrás, 7 adelante) coloreada por fase —
/// alternativa liviana a un calendario mensual completo, dado que el resto
/// de la pantalla ya muestra la fase actual en detalle.
class PhaseCalendarStrip extends ConsumerWidget {
  const PhaseCalendarStrip({super.key});

  Color _colorFor(BuildContext context, CyclePhase phase) {
    final scheme = Theme.of(context).colorScheme;
    return switch (phase) {
      CyclePhase.menstruation => scheme.errorContainer,
      CyclePhase.follicular => scheme.primaryContainer,
      CyclePhase.ovulation => scheme.tertiaryContainer,
      CyclePhase.lutealEarly => scheme.secondaryContainer,
      CyclePhase.lutealLate => scheme.surfaceContainerHighest,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final today = DateTime.now();
    final from = DateTime(today.year, today.month, today.day).subtract(const Duration(days: 7));
    final to = DateTime(today.year, today.month, today.day).add(const Duration(days: 7));

    return AsyncValueView<List<CyclePhaseDay>>.future(
      future: ref.read(menstrualCycleRepositoryProvider).getPhaseCalendar(from: from, to: to),
      errorMessage: l10n.commonSomethingWentWrong,
      builder: (context, days) {
        if (days.isEmpty) return const SizedBox.shrink();

        final dayFormat = DateFormat.Md(l10n.localeName);
        return SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            separatorBuilder: (_, _) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              final day = days[index];
              final isToday = day.date.year == today.year && day.date.month == today.month && day.date.day == today.day;
              return Container(
                width: 44,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: _colorFor(context, day.phase),
                  borderRadius: BorderRadius.circular(8),
                  border: isToday ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2) : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text(dayFormat.format(day.date), style: Theme.of(context).textTheme.bodySmall)],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
