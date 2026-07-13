class Hba1cTrendPoint {
  const Hba1cTrendPoint({
    required this.month,
    required this.estimatedHba1c,
    required this.averageGlucose,
    required this.totalReadings,
  });

  final String month;
  final double? estimatedHba1c;
  final double? averageGlucose;
  final int totalReadings;
}
