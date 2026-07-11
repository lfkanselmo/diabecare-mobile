import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/hba1c_trend_point.dart';

/// Tendencia mensual de HbA1c estimada — mismo dato que la web, reutilizando
/// el patrón de `GlucoseChart` (línea simple con `fl_chart`).
class Hba1cTrendChart extends StatelessWidget {
  const Hba1cTrendChart({super.key, required this.points});

  final List<Hba1cTrendPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const Center(child: Text('—'));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final spots = [for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].estimatedHba1c)];

    return LineChart(
      LineChartData(
        minY: 0,
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= points.length) return const SizedBox.shrink();
                return Text(points[index].month, style: Theme.of(context).textTheme.bodySmall);
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            barWidth: 2,
            color: isDark ? AppColors.primaryDark : AppColors.primary,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}
