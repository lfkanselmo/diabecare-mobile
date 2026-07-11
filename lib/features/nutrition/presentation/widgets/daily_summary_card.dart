import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
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
    return FutureBuilder<DailySummary>(
      future: ref.read(mealRepositoryProvider).getDailySummary(DateTime.now()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Card(child: Padding(padding: EdgeInsets.all(16), child: LinearProgressIndicator()));
        }
        final summary = snapshot.data!;
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
