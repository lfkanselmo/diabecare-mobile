import '../entities/hba1c_trend_point.dart';
import '../entities/vital_sign.dart';

/// `watchVitals`/`getLatest` leen siempre de la caché local (Drift).
/// `getHba1cTrend` es una agregación que solo el servidor puede calcular —
/// red-first, sin contraparte local (igual patrón que AGP de glucosa).
abstract interface class VitalSignRepository {
  Stream<List<VitalSign>> watchVitals({required DateTime from, required DateTime to});

  Future<VitalSign?> getLatest();

  /// Sin validación client-side — todos los campos son opcionales, igual
  /// que `RegisterVitalSignRequest` del backend.
  Future<VitalSign> register({
    double? weightKg,
    double? heightCm,
    int? systolicBp,
    int? diastolicBp,
    int? heartRate,
    double? hba1c,
    required DateTime measuredAt,
    String? notes,
  });

  Future<List<Hba1cTrendPoint>> getHba1cTrend({int months = 6});

  Future<void> pullChanges();
}
