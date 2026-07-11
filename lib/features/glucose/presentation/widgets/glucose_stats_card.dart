import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/glucose_stats.dart';

/// Mismos umbrales que `dashboard.component.ts`: HbA1c `<7 bien / 7-8 alerta
/// / ≥8 peligro`; CV `≥36%` alta variabilidad (consenso ATTD).
class GlucoseStatsCard extends StatelessWidget {
  const GlucoseStatsCard({super.key, required this.stats});

  final GlucoseStats stats;

  Color _hba1cColor(bool isDark) {
    if (stats.estimatedHba1c >= 8) return isDark ? AppColors.dangerDark : AppColors.danger;
    if (stats.estimatedHba1c >= 7) return isDark ? AppColors.warningDark : AppColors.warning;
    return isDark ? AppColors.successDark : AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final highVariability = stats.coefficientOfVariation >= 36;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.dashboardAvgGlucose7d, style: Theme.of(context).textTheme.labelLarge),
            Text('${stats.average.toStringAsFixed(0)} mg/dL', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(l10n.dashboardEstimatedHba1c),
                const SizedBox(width: 8),
                Text(
                  '${stats.estimatedHba1c.toStringAsFixed(1)}%',
                  style: TextStyle(color: _hba1cColor(isDark), fontWeight: FontWeight.bold),
                ),
              ],
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ((stats.estimatedHba1c - 4) / 10).clamp(0, 1),
                color: _hba1cColor(isDark),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 12),
            Text('${l10n.dashboardTimeInRange}: ${stats.timeInRangePercent.toStringAsFixed(0)}%'),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(l10n.dashboardGlycemicVariability),
                const SizedBox(width: 8),
                Text(
                  '${stats.coefficientOfVariation.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: highVariability ? (isDark ? AppColors.warningDark : AppColors.warning) : null,
                    fontWeight: highVariability ? FontWeight.bold : null,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  highVariability ? l10n.dashboardHighVariability : l10n.dashboardAcceptableVariability,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
