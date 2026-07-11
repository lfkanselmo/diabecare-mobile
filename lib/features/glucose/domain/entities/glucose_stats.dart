/// Mirror de `GlucoseStatsResponse` del backend.
class GlucoseStats {
  const GlucoseStats({
    required this.average,
    required this.standardDeviation,
    required this.coefficientOfVariation,
    required this.estimatedHba1c,
    required this.timeInRangePercent,
    required this.timeBelowRangePercent,
    required this.timeAboveRangePercent,
    required this.totalReadings,
  });

  final double average;
  final double standardDeviation;
  final double coefficientOfVariation;
  final double estimatedHba1c;
  final double timeInRangePercent;
  final double timeBelowRangePercent;
  final double timeAboveRangePercent;
  final int totalReadings;
}

/// Un bucket horario del perfil AGP (Ambulatory Glucose Profile) — 24 por
/// rango de fechas consultado, agregando percentiles sin importar el día.
class AgpBucket {
  const AgpBucket({
    required this.hour,
    required this.readingCount,
    this.p10,
    this.p25,
    this.median,
    this.p75,
    this.p90,
  });

  final int hour;
  final int readingCount;
  final double? p10;
  final double? p25;
  final double? median;
  final double? p75;
  final double? p90;
}
