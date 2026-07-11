class DailySummary {
  const DailySummary({
    required this.date,
    required this.totalCalories,
    required this.totalCarbohydrates,
    required this.totalProteins,
    required this.totalFats,
    required this.goalReached,
    this.calorieGoal,
  });

  final DateTime date;
  final double totalCalories;
  final double totalCarbohydrates;
  final double totalProteins;
  final double totalFats;
  final int? calorieGoal;
  final bool goalReached;
}
