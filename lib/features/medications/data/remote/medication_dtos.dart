// DTOs de red — mirror exacto de `MedicationController`.

class MedicationResponseDto {
  MedicationResponseDto({
    required this.medicationId,
    required this.name,
    required this.type,
    required this.dose,
    required this.doseUnit,
    required this.frequency,
    required this.active,
    this.startDate,
    this.notes,
    this.updatedAt,
  });

  factory MedicationResponseDto.fromJson(Map<String, dynamic> json) => MedicationResponseDto(
    medicationId: json['medicationId'] as String,
    name: json['name'] as String,
    type: json['type'] as String,
    dose: (json['dose'] as num).toDouble(),
    doseUnit: json['doseUnit'] as String,
    frequency: json['frequency'] as String,
    startDate: json['startDate'] == null ? null : DateTime.parse(json['startDate'] as String),
    active: json['active'] as bool,
    notes: json['notes'] as String?,
    updatedAt: json['updatedAt'] == null ? null : DateTime.parse(json['updatedAt'] as String),
  );

  final String medicationId;
  final String name;
  final String type;
  final double dose;
  final String doseUnit;
  final String frequency;
  final DateTime? startDate;
  final bool active;
  final String? notes;
  final DateTime? updatedAt;
}

class InsulinCalculationResponseDto {
  InsulinCalculationResponseDto({
    required this.correctionDose,
    required this.mealDose,
    required this.totalDose,
    required this.explanation,
    required this.disclaimer,
  });

  factory InsulinCalculationResponseDto.fromJson(Map<String, dynamic> json) => InsulinCalculationResponseDto(
    correctionDose: (json['correctionDose'] as num).toDouble(),
    mealDose: (json['mealDose'] as num).toDouble(),
    totalDose: (json['totalDose'] as num).toDouble(),
    explanation: json['explanation'] as String,
    disclaimer: json['disclaimer'] as String,
  );

  final double correctionDose;
  final double mealDose;
  final double totalDose;
  final String explanation;
  final String disclaimer;
}
