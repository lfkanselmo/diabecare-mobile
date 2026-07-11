import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/alert.dart';

/// Port de los mapeos color/ícono por severidad de `SystemConfigService`
/// (web) — reutiliza los colores de marca ya definidos en `AppColors`
/// desde Fase 0, no se reinventan.
class AlertStyle {
  AlertStyle._();

  static Color color(AlertSeverity severity, {required bool isDark}) {
    switch (severity) {
      case AlertSeverity.success:
        return isDark ? AppColors.successDark : AppColors.success;
      case AlertSeverity.info:
        return AppColors.info;
      case AlertSeverity.warning:
        return isDark ? AppColors.warningDark : AppColors.warning;
      case AlertSeverity.danger:
        return isDark ? AppColors.dangerDark : AppColors.danger;
    }
  }

  static Color background(AlertSeverity severity, {required bool isDark}) {
    return color(severity, isDark: isDark).withValues(alpha: 0.15);
  }

  static IconData icon(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.success:
        return Icons.check_circle;
      case AlertSeverity.info:
        return Icons.info;
      case AlertSeverity.warning:
        return Icons.warning_amber;
      case AlertSeverity.danger:
        return Icons.dangerous;
    }
  }
}
