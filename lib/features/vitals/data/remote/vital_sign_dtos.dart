// DTOs de red — mirror exacto de `VitalSignController`.

class VitalSignResponseDto {
  VitalSignResponseDto({
    required this.vitalId,
    required this.measuredAt,
    this.weightKg,
    this.heightCm,
    this.bmi,
    this.bmiCategory,
    this.systolicBp,
    this.diastolicBp,
    this.heartRate,
    this.hba1c,
    this.notes,
    this.updatedAt,
  });

  factory VitalSignResponseDto.fromJson(Map<String, dynamic> json) => VitalSignResponseDto(
    vitalId: json['vitalId'] as String,
    weightKg: (json['weightKg'] as num?)?.toDouble(),
    heightCm: (json['heightCm'] as num?)?.toDouble(),
    bmi: (json['bmi'] as num?)?.toDouble(),
    bmiCategory: json['bmiCategory'] as String?,
    systolicBp: json['systolicBp'] as int?,
    diastolicBp: json['diastolicBp'] as int?,
    heartRate: json['heartRate'] as int?,
    hba1c: (json['hba1c'] as num?)?.toDouble(),
    measuredAt: DateTime.parse(json['measuredAt'] as String),
    notes: json['notes'] as String?,
    updatedAt: json['updatedAt'] == null ? null : DateTime.parse(json['updatedAt'] as String),
  );

  final String vitalId;
  final double? weightKg;
  final double? heightCm;
  final double? bmi;
  final String? bmiCategory;
  final int? systolicBp;
  final int? diastolicBp;
  final int? heartRate;
  final double? hba1c;
  final DateTime measuredAt;
  final String? notes;
  final DateTime? updatedAt;
}

class Hba1cTrendResponseDto {
  Hba1cTrendResponseDto({
    required this.month,
    required this.estimatedHba1c,
    required this.averageGlucose,
    required this.totalReadings,
  });

  factory Hba1cTrendResponseDto.fromJson(Map<String, dynamic> json) => Hba1cTrendResponseDto(
    month: json['month'] as String,
    estimatedHba1c: (json['estimatedHba1c'] as num?)?.toDouble(),
    averageGlucose: (json['averageGlucose'] as num?)?.toDouble(),
    totalReadings: json['totalReadings'] as int,
  );

  final String month;
  final double? estimatedHba1c;
  final double? averageGlucose;
  final int totalReadings;
}
