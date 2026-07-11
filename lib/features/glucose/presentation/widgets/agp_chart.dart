import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/glucose_stats.dart';

/// Perfil de glucosa ambulatorio (AGP): 24 buckets horarios con percentiles
/// p10/p25/mediana/p75/p90 — mismo dato que `agp-chart.component.ts`, sin el
/// truco de "stacked area" de ECharts (acá las bandas se grafican directo
/// con `BetweenBarsData`).
class AgpChart extends StatelessWidget {
  const AgpChart({super.key, required this.buckets, required this.targetMin, required this.targetMax});

  final List<AgpBucket> buckets;
  final double targetMin;
  final double targetMax;

  @override
  Widget build(BuildContext context) {
    final withData = buckets.where((b) => b.readingCount > 0).toList();
    if (withData.isEmpty) {
      return const Center(child: Text('—'));
    }

    final sorted = buckets.toList()..sort((a, b) => a.hour.compareTo(b.hour));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    List<FlSpot> lineFor(double? Function(AgpBucket) selector) {
      return [
        for (final bucket in sorted)
          if (selector(bucket) != null) FlSpot(bucket.hour.toDouble(), selector(bucket)!),
      ];
    }

    final p10 = lineFor((b) => b.p10);
    final p90 = lineFor((b) => b.p90);
    final p25 = lineFor((b) => b.p25);
    final p75 = lineFor((b) => b.p75);
    final median = lineFor((b) => b.median);

    Color primary = isDark ? AppColors.primaryDark : AppColors.primary;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 23,
        rangeAnnotations: RangeAnnotations(
          horizontalRangeAnnotations: [
            HorizontalRangeAnnotation(
              y1: targetMin,
              y2: targetMax,
              color: AppColors.success.withValues(alpha: 0.08),
            ),
          ],
        ),
        lineBarsData: [
          LineChartBarData(spots: p10, isCurved: true, barWidth: 0, dotData: const FlDotData(show: false)),
          LineChartBarData(spots: p90, isCurved: true, barWidth: 0, dotData: const FlDotData(show: false)),
          LineChartBarData(spots: p25, isCurved: true, barWidth: 0, dotData: const FlDotData(show: false)),
          LineChartBarData(spots: p75, isCurved: true, barWidth: 0, dotData: const FlDotData(show: false)),
          LineChartBarData(
            spots: median,
            isCurved: true,
            barWidth: 3,
            color: primary,
            dotData: const FlDotData(show: false),
          ),
        ],
        betweenBarsData: [
          BetweenBarsData(fromIndex: 0, toIndex: 1, color: primary.withValues(alpha: 0.10)),
          BetweenBarsData(fromIndex: 2, toIndex: 3, color: primary.withValues(alpha: 0.22)),
        ],
      ),
    );
  }
}
