import 'package:flutter/material.dart';

import '../../domain/entities/alert.dart';
import '../style/alert_style.dart';

/// Lista plana, sin dismiss ni paginación — igual que
/// `alerts-panel.component.html` en la web.
class AlertsPanel extends StatelessWidget {
  const AlertsPanel({super.key, required this.alerts});

  final List<Alert> alerts;

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        for (final alert in alerts)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AlertStyle.background(alert.severity, isDark: isDark),
              border: Border(
                left: BorderSide(color: AlertStyle.color(alert.severity, isDark: isDark), width: 4),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(AlertStyle.icon(alert.severity), color: AlertStyle.color(alert.severity, isDark: isDark)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(alert.title, style: Theme.of(context).textTheme.titleSmall),
                      Text(alert.message, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
