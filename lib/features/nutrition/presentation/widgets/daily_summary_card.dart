import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../domain/entities/daily_summary.dart';
import '../providers/nutrition_providers.dart';

/// Tarjeta de resumen diario para el dashboard — lectura directa sin caché
/// TTL (no tiene el patrón de re-consulta repetida que justificó cachear
/// stats de glucosa, ver plan de Fase 2).
class DailySummaryCard extends ConsumerWidget {
  const DailySummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return AsyncValueView<DailySummary>.future(
      future: ref.read(mealRepositoryProvider).getDailySummary(DateTime.now()),
      errorMessage: l10n.commonSomethingWentWrong,
      loadingBuilder: (context) =>
          const Card(child: Padding(padding: EdgeInsets.all(16), child: LinearProgressIndicator())),
      builder: (context, summary) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.nutritionDailySummaryTitle, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('${summary.totalCalories.toStringAsFixed(0)} kcal'),
                Text(l10n.nutritionDailySummaryMacros(
                  summary.totalCarbohydrates.toStringAsFixed(0),
                  summary.totalProteins.toStringAsFixed(0),
                  summary.totalFats.toStringAsFixed(0),
                )),
              ],
            ),
          ),
        );
      },
    );
  }
}
