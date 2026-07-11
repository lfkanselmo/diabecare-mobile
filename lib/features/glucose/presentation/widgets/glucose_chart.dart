import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/glucose_reading.dart';
import '../../domain/entities/glucose_status.dart';

/// Línea de lecturas + banda sombreada del rango objetivo — mismo dato que
/// `glucose-chart.component.ts` de la web, sin el overlay de comidas/
/// ejercicio (dominios que no existen todavía en el móvil, ver ROADMAP.md).
class GlucoseChart extends StatelessWidget {
  const GlucoseChart({
    super.key,
    required this.readings,
    required this.from,
    required this.targetMin,
    required this.targetMax,
  });

  final List<GlucoseReading> readings;
  final DateTime from;
  final double targetMin;
  final double targetMax;

  double _xFor(DateTime dateTime) => dateTime.difference(from).inMinutes.toDouble();

  Color _colorFor(GlucoseStatus? status, bool isDark) {
    switch (status) {
      case GlucoseStatus.criticallyLow:
        return isDark ? AppColors.glucoseCriticallyLowDark : AppColors.glucoseCriticallyLow;
      case GlucoseStatus.low:
        return isDark ? AppColors.glucoseLowDark : AppColors.glucoseLow;
      case GlucoseStatus.normal:
        return isDark ? AppColors.glucoseNormalDark : AppColors.glucoseNormal;
      case GlucoseStatus.high:
        return isDark ? AppColors.glucoseHighDark : AppColors.glucoseHigh;
      case GlucoseStatus.criticallyHigh:
        return isDark ? AppColors.glucoseCriticallyHighDark : AppColors.glucoseCriticallyHigh;
      case null:
        return isDark ? AppColors.primaryDark : AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return const Center(child: Text('—'));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sorted = readings.toList()..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
    final spots = [for (final r in sorted) FlSpot(_xFor(r.measuredAt), r.value)];

    return LineChart(
      LineChartData(
        minY: 0,
        rangeAnnotations: RangeAnnotations(
          horizontalRangeAnnotations: [
            HorizontalRangeAnnotation(y1: targetMin, y2: targetMax, color: AppColors.success.withValues(alpha: 0.12)),
          ],
        ),
        titlesData: const FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            barWidth: 2,
            color: isDark ? AppColors.primaryDark : AppColors.primary,
            dotData: FlDotData(
              getDotPainter: (spot, percent, bar, index) {
                final status = sorted[index].status;
                return FlDotCirclePainter(radius: 3, color: _colorFor(status, isDark));
              },
            ),
          ),
        ],
      ),
    );
  }
}
