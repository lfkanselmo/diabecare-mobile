import 'cycle_day_entry.dart';
import 'cycle_phase.dart';

class CycleHistoryItem {
  const CycleHistoryItem({required this.cycleId, required this.startDate, this.endDate, this.actualPeriodLengthDays});

  final String cycleId;
  final DateTime startDate;
  final DateTime? endDate;
  final int? actualPeriodLengthDays;
}

/// Todo calculado por el servidor (proyecciones, guía de glucosa por fase) —
/// red-first, sin contraparte local (mismo patrón que stats/AGP de glucosa).
class MenstrualCycleStatus {
  const MenstrualCycleStatus({
    required this.currentPhase,
    required this.currentPhaseLabel,
    required this.dayOfCycle,
    required this.isOngoing,
    required this.isOpenTooLong,
    required this.isProjectionStale,
    required this.nextCycleStart,
    required this.daysUntilNextCycle,
    required this.glucoseGuidance,
    required this.history,
    this.periodStartDate,
    this.averageCycleLength,
    this.averagePeriodLength,
    this.todayEntry,
  });

  final CyclePhase currentPhase;
  final String currentPhaseLabel;
  final int dayOfCycle;
  final bool isOngoing;
  final bool isOpenTooLong;
  final bool isProjectionStale;
  final DateTime? periodStartDate;
  final DateTime nextCycleStart;
  final int daysUntilNextCycle;
  final String glucoseGuidance;
  final int? averageCycleLength;
  final int? averagePeriodLength;
  final CycleDayEntry? todayEntry;
  final List<CycleHistoryItem> history;
}
