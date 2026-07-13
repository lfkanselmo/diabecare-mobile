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
    // Meses sin lecturas no traen estimatedHba1c (el backend omite el campo) —
    // se excluyen del trazo en vez de graficar un falso 0%. Renumerados a un
    // eje contiguo (0..N) en vez de conservar el índice original: dejar huecos
    // en el eje X (p.ej. solo índices 4 y 5 de 6) hace que fl_chart calcule un
    // dominio angosto y genere ticks fraccionarios repetidos.
    final plottable = [
      for (final point in points)
        if (point.estimatedHba1c != null) (month: point.month, hba1c: point.estimatedHba1c!),
    ];
    if (plottable.isEmpty) {
      return const Center(child: Text('—'));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final spots = [for (var i = 0; i < plottable.length; i++) FlSpot(i.toDouble(), plottable[i].hba1c)];

    return LineChart(
      LineChartData(
        minY: 0,
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= plottable.length) return const SizedBox.shrink();
                return Text(plottable[index].month, style: Theme.of(context).textTheme.bodySmall);
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
