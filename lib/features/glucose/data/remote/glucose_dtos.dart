// DTOs de red — mirror exacto de los DTOs de `diabecare-api`
// (`GlucoseController`), nombres de campo tal cual.

class GlucoseReadingResponseDto {
  GlucoseReadingResponseDto({
    required this.readingId,
    required this.value,
    required this.unit,
    required this.readingType,
    required this.status,
    required this.measuredAt,
    required this.notes,
    required this.deviceSource,
    required this.updatedAt,
  });

  factory GlucoseReadingResponseDto.fromJson(Map<String, dynamic> json) => GlucoseReadingResponseDto(
    readingId: json['readingId'] as String,
    value: (json['value'] as num).toDouble(),
    unit: json['unit'] as String,
    readingType: json['readingType'] as String,
    status: json['status'] as String?,
    measuredAt: DateTime.parse(json['measuredAt'] as String),
    notes: json['notes'] as String?,
    deviceSource: json['deviceSource'] as String?,
    updatedAt: json['updatedAt'] == null ? null : DateTime.parse(json['updatedAt'] as String),
  );

  final String readingId;
  final double value;
  final String unit;
  final String readingType;
  final String? status;
  final DateTime measuredAt;
  final String? notes;
  final String? deviceSource;
  final DateTime? updatedAt;
}

class GlucoseStatsResponseDto {
  GlucoseStatsResponseDto({
    required this.average,
    required this.standardDeviation,
    required this.coefficientOfVariation,
    required this.estimatedHba1c,
    required this.timeInRangePercent,
    required this.timeBelowRangePercent,
    required this.timeAboveRangePercent,
    required this.totalReadings,
  });

  factory GlucoseStatsResponseDto.fromJson(Map<String, dynamic> json) => GlucoseStatsResponseDto(
    average: (json['average'] as num).toDouble(),
    standardDeviation: (json['standardDeviation'] as num).toDouble(),
    coefficientOfVariation: (json['coefficientOfVariation'] as num).toDouble(),
    estimatedHba1c: (json['estimatedHba1c'] as num).toDouble(),
    timeInRangePercent: (json['timeInRangePercent'] as num).toDouble(),
    timeBelowRangePercent: (json['timeBelowRangePercent'] as num).toDouble(),
    timeAboveRangePercent: (json['timeAboveRangePercent'] as num).toDouble(),
    totalReadings: json['totalReadings'] as int,
  );

  final double average;
  final double standardDeviation;
  final double coefficientOfVariation;
  final double estimatedHba1c;
  final double timeInRangePercent;
  final double timeBelowRangePercent;
  final double timeAboveRangePercent;
  final int totalReadings;
}

class AgpBucketResponseDto {
  AgpBucketResponseDto({
    required this.hour,
    required this.readingCount,
    this.p10,
    this.p25,
    this.median,
    this.p75,
    this.p90,
  });

  factory AgpBucketResponseDto.fromJson(Map<String, dynamic> json) => AgpBucketResponseDto(
    hour: json['hour'] as int,
    readingCount: json['readingCount'] as int,
    p10: (json['p10'] as num?)?.toDouble(),
    p25: (json['p25'] as num?)?.toDouble(),
    median: (json['median'] as num?)?.toDouble(),
    p75: (json['p75'] as num?)?.toDouble(),
    p90: (json['p90'] as num?)?.toDouble(),
  );

  final int hour;
  final int readingCount;
  final double? p10;
  final double? p25;
  final double? median;
  final double? p75;
  final double? p90;
}
