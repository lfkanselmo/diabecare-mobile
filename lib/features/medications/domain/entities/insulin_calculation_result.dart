class InsulinCalculationResult {
  const InsulinCalculationResult({
    required this.correctionDose,
    required this.mealDose,
    required this.totalDose,
    required this.explanation,
    required this.disclaimer,
  });

  final double correctionDose;
  final double mealDose;
  final double totalDose;
  final String explanation;
  final String disclaimer;
}
