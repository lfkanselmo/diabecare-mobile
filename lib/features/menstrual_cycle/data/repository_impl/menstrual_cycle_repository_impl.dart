import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/cycle_day_entry.dart';
import '../../domain/entities/cycle_phase.dart';
import '../../domain/entities/cycle_phase_day.dart';
import '../../domain/entities/cycle_symptom.dart';
import '../../domain/entities/flow_intensity.dart';
import '../../domain/entities/menstrual_cycle_status.dart';
import '../../domain/entities/symptom_severity.dart';
import '../../domain/repositories/menstrual_cycle_repository.dart';
import '../remote/menstrual_cycle_api_client.dart';
import '../remote/menstrual_cycle_dtos.dart';

class MenstrualCycleRepositoryImpl implements MenstrualCycleRepository {
  MenstrualCycleRepositoryImpl({required MenstrualCycleApiClient apiClient, required AuthRepository authRepository})
    : _apiClient = apiClient,
      _authRepository = authRepository;

  final MenstrualCycleApiClient _apiClient;
  final AuthRepository _authRepository;

  @override
  Future<MenstrualCycleStatus> registerCycle({required DateTime startDate, String? notes}) async {
    final patientId = await _requirePatientId();
    final dto = await _apiClient.register(patientId: patientId, startDate: startDate, notes: notes);
    return _statusToDomain(dto);
  }

  @override
  Future<MenstrualCycleStatus> finishPeriod({required DateTime endDate}) async {
    final patientId = await _requirePatientId();
    final dto = await _apiClient.finishPeriod(patientId: patientId, endDate: endDate);
    return _statusToDomain(dto);
  }

  @override
  Future<CycleDayEntry> registerDayEntry({
    required DateTime entryDate,
    required FlowIntensity flowIntensity,
    String? notes,
    List<SymptomInput> symptoms = const [],
  }) async {
    final patientId = await _requirePatientId();
    final dto = await _apiClient.registerDayEntry(
      patientId: patientId,
      entryDate: entryDate,
      flowIntensity: flowIntensity.wireValue,
      notes: notes,
      symptoms: [for (final s in symptoms) (symptom: s.symptom.wireValue, severity: s.severity.wireValue)],
    );
    return _dayEntryToDomain(dto);
  }

  @override
  Future<MenstrualCycleStatus> getStatus() async {
    final patientId = await _requirePatientId();
    final dto = await _apiClient.getStatus(patientId: patientId);
    return _statusToDomain(dto);
  }

  @override
  Future<List<CyclePhaseDay>> getPhaseCalendar({required DateTime from, required DateTime to}) async {
    final patientId = await _requirePatientId();
    final days = await _apiClient.getPhaseCalendar(patientId: patientId, from: from, to: to);
    return days.map((d) => CyclePhaseDay(date: d.date, phase: CyclePhase.fromWire(d.phase))).toList();
  }

  Future<String> _requirePatientId() async {
    final session = await _authRepository.loadSession();
    final patientId = session?.patient?.patientId;
    if (patientId == null) {
      throw StateError('No hay un paciente asociado a la sesión actual');
    }
    return patientId;
  }

  MenstrualCycleStatus _statusToDomain(MenstrualCycleStatusResponseDto dto) {
    return MenstrualCycleStatus(
      currentPhase: CyclePhase.fromWire(dto.currentPhase),
      currentPhaseLabel: dto.currentPhaseLabel,
      dayOfCycle: dto.dayOfCycle,
      isOngoing: dto.isOngoing,
      isOpenTooLong: dto.isOpenTooLong,
      isProjectionStale: dto.isProjectionStale,
      periodStartDate: dto.periodStartDate,
      nextCycleStart: dto.nextCycleStart,
      daysUntilNextCycle: dto.daysUntilNextCycle,
      glucoseGuidance: dto.glucoseGuidance,
      averageCycleLength: dto.averageCycleLength,
      averagePeriodLength: dto.averagePeriodLength,
      todayEntry: dto.todayEntry == null ? null : _dayEntryToDomain(dto.todayEntry!),
      history: dto.history
          .map(
            (h) => CycleHistoryItem(
              cycleId: h.cycleId,
              startDate: h.startDate,
              endDate: h.endDate,
              actualPeriodLengthDays: h.actualPeriodLengthDays,
            ),
          )
          .toList(),
    );
  }

  CycleDayEntry _dayEntryToDomain(CycleDayEntryResponseDto dto) {
    return CycleDayEntry(
      dayEntryId: dto.dayEntryId,
      entryDate: dto.entryDate,
      flowIntensity: FlowIntensity.fromWire(dto.flowIntensity),
      flowIntensityLabel: dto.flowIntensityLabel,
      notes: dto.notes,
      symptoms: dto.symptoms
          .map(
            (s) => CycleDaySymptomEntry(
              symptom: CycleSymptom.fromWire(s.symptom),
              symptomLabel: s.symptomLabel,
              severity: SymptomSeverity.fromWire(s.severity),
            ),
          )
          .toList(),
    );
  }
}
