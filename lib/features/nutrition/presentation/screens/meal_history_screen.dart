import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../domain/entities/meal_entry.dart';
import '../providers/nutrition_providers.dart';

class MealHistoryScreen extends ConsumerWidget {
  const MealHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 30));
    final to = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final mealsAsync = ref.watch(mealsByDayProvider(from: from, to: to));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.nutritionHistoryTitle)),
      body: SafeArea(
        child: mealsAsync.when(
          data: (meals) => meals.isEmpty
              ? Center(child: Text(l10n.nutritionHistoryEmpty))
              : ListView.builder(
                  itemCount: meals.length,
                  itemBuilder: (context, index) => _MealTile(meal: meals[index]),
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(child: Text(l10n.nutritionErrorMessage)),
        ),
      ),
    );
  }
}

class _MealTile extends StatelessWidget {
  const _MealTile({required this.meal});

  final MealEntry meal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat.yMd(l10n.localeName).add_Hm();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(_mealTypeLabel(l10n, meal)),
        subtitle: Text(dateFormat.format(meal.consumedAt)),
        trailing: meal.totalCalories == null
            ? Icon(Icons.sync, color: Theme.of(context).colorScheme.outline)
            : Text('${meal.totalCalories!.toStringAsFixed(0)} kcal'),
      ),
    );
  }

  String _mealTypeLabel(AppLocalizations l10n, MealEntry meal) {
    switch (meal.mealType.wireValue) {
      case 'BREAKFAST':
        return l10n.nutritionMealTypeBreakfast;
      case 'LUNCH':
        return l10n.nutritionMealTypeLunch;
      case 'DINNER':
        return l10n.nutritionMealTypeDinner;
      default:
        return l10n.nutritionMealTypeSnack;
    }
  }
}
