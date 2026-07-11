import '../../../../core/sync/sync_status.dart';
import 'bmi_category.dart';

/// `bmi`/`bmiCategory` son calculados por el servidor — nulos hasta que el
/// registro se sincroniza (igual patrón que `status` en `GlucoseReading`).
/// Todos los campos de dominio son opcionales, igual que la web (sin
/// inventar validación client-side que el backend no exige).
class VitalSign {
  const VitalSign({
    required this.id,
    required this.measuredAt,
    required this.syncStatus,
    this.weightKg,
    this.heightCm,
    this.systolicBp,
    this.diastolicBp,
    this.heartRate,
    this.hba1c,
    this.notes,
    this.bmi,
    this.bmiCategory,
    this.updatedAt,
  });

  final String id;
  final DateTime measuredAt;
  final SyncStatus syncStatus;
  final double? weightKg;
  final double? heightCm;
  final int? systolicBp;
  final int? diastolicBp;
  final int? heartRate;
  final double? hba1c;
  final String? notes;
  final double? bmi;
  final BmiCategory? bmiCategory;
  final DateTime? updatedAt;
}
