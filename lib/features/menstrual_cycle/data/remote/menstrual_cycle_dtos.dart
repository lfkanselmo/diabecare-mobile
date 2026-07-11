// DTOs de red — mirror exacto de `MenstrualCycleController`.

class SymptomEntryDto {
  SymptomEntryDto({required this.symptom, required this.symptomLabel, required this.severity});

  factory SymptomEntryDto.fromJson(Map<String, dynamic> json) => SymptomEntryDto(
    symptom: json['symptom'] as String,
    symptomLabel: json['symptomLabel'] as String,
    severity: json['severity'] as String,
  );

  final String symptom;
  final String symptomLabel;
  final String severity;
}

class CycleDayEntryResponseDto {
  CycleDayEntryResponseDto({
    required this.dayEntryId,
    required this.entryDate,
    required this.flowIntensity,
    required this.flowIntensityLabel,
    required this.symptoms,
    this.notes,
  });

  factory CycleDayEntryResponseDto.fromJson(Map<String, dynamic> json) => CycleDayEntryResponseDto(
    dayEntryId: json['dayEntryId'] as String,
    entryDate: DateTime.parse(json['entryDate'] as String),
    flowIntensity: json['flowIntensity'] as String,
    flowIntensityLabel: json['flowIntensityLabel'] as String,
    notes: json['notes'] as String?,
    symptoms: (json['symptoms'] as List<dynamic>)
        .map((e) => SymptomEntryDto.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  final String dayEntryId;
  final DateTime entryDate;
  final String flowIntensity;
  final String flowIntensityLabel;
  final String? notes;
  final List<SymptomEntryDto> symptoms;
}

class CycleHistoryItemDto {
  CycleHistoryItemDto({required this.cycleId, required this.startDate, this.endDate, this.actualPeriodLengthDays});

  factory CycleHistoryItemDto.fromJson(Map<String, dynamic> json) => CycleHistoryItemDto(
    cycleId: json['cycleId'] as String,
    startDate: DateTime.parse(json['startDate'] as String),
    endDate: json['endDate'] == null ? null : DateTime.parse(json['endDate'] as String),
    actualPeriodLengthDays: json['actualPeriodLengthDays'] as int?,
  );

  final String cycleId;
  final DateTime startDate;
  final DateTime? endDate;
  final int? actualPeriodLengthDays;
}

class MenstrualCycleStatusResponseDto {
  MenstrualCycleStatusResponseDto({
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

  factory MenstrualCycleStatusResponseDto.fromJson(Map<String, dynamic> json) => MenstrualCycleStatusResponseDto(
    currentPhase: json['currentPhase'] as String,
    currentPhaseLabel: json['currentPhaseLabel'] as String,
    dayOfCycle: json['dayOfCycle'] as int,
    isOngoing: json['isOngoing'] as bool,
    isOpenTooLong: json['isOpenTooLong'] as bool,
    isProjectionStale: json['isProjectionStale'] as bool,
    periodStartDate: json['periodStartDate'] == null ? null : DateTime.parse(json['periodStartDate'] as String),
    nextCycleStart: DateTime.parse(json['nextCycleStart'] as String),
    daysUntilNextCycle: json['daysUntilNextCycle'] as int,
    glucoseGuidance: json['glucoseGuidance'] as String,
    averageCycleLength: json['averageCycleLength'] as int?,
    averagePeriodLength: json['averagePeriodLength'] as int?,
    todayEntry: json['todayEntry'] == null
        ? null
        : CycleDayEntryResponseDto.fromJson(json['todayEntry'] as Map<String, dynamic>),
    history: (json['history'] as List<dynamic>)
        .map((e) => CycleHistoryItemDto.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  final String currentPhase;
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
  final CycleDayEntryResponseDto? todayEntry;
  final List<CycleHistoryItemDto> history;
}

class CyclePhaseDayResponseDto {
  CyclePhaseDayResponseDto({required this.date, required this.phase});

  factory CyclePhaseDayResponseDto.fromJson(Map<String, dynamic> json) =>
      CyclePhaseDayResponseDto(date: DateTime.parse(json['date'] as String), phase: json['phase'] as String);

  final DateTime date;
  final String phase;
}
