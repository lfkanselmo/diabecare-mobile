import '../entities/cycle_day_entry.dart';
import '../entities/cycle_phase_day.dart';
import '../entities/cycle_symptom.dart';
import '../entities/flow_intensity.dart';
import '../entities/menstrual_cycle_status.dart';
import '../entities/symptom_severity.dart';

class SymptomInput {
  const SymptomInput({required this.symptom, required this.severity});

  final CycleSymptom symptom;
  final SymptomSeverity severity;
}

/// Dominio 100% online — no hay tabla Drift ni `SyncableRepository`, todo se
/// calcula server-side (proyecciones de fase, guía de glucosa), igual patrón
/// que stats/AGP de glucosa (ARCHITECTURE.md §4.6).
abstract interface class MenstrualCycleRepository {
  Future<MenstrualCycleStatus> registerCycle({required DateTime startDate, String? notes});

  Future<MenstrualCycleStatus> finishPeriod({required DateTime endDate});

  Future<CycleDayEntry> registerDayEntry({
    required DateTime entryDate,
    required FlowIntensity flowIntensity,
    String? notes,
    List<SymptomInput> symptoms,
  });

  Future<MenstrualCycleStatus> getStatus();

  Future<List<CyclePhaseDay>> getPhaseCalendar({required DateTime from, required DateTime to});
}
