import '../entities/dose_unit.dart';
import '../entities/insulin_calculation_result.dart';
import '../entities/medication.dart';
import '../entities/medication_frequency.dart';
import '../entities/medication_type.dart';

abstract interface class MedicationRepository {
  Stream<List<Medication>> watchActive();

  Future<Medication> register({
    required String name,
    required MedicationType type,
    required double dose,
    required DoseUnit doseUnit,
    required MedicationFrequency frequency,
    DateTime? startDate,
    String? notes,
  });

  /// Desactiva (nunca borra) — encola la baja para el motor de sync si el
  /// medicamento ya está sincronizado.
  Future<void> deactivate(String id);

  Future<void> pullChanges();

  /// Todo el cálculo es del servidor — si el perfil de insulina no está
  /// configurado, lanza y la pantalla debe redirigir al formulario de perfil.
  Future<InsulinCalculationResult> calculateInsulinDose({
    required double currentGlucose,
    double? carbsToEat,
    required bool beforeMeal,
  });

  /// Actualiza el perfil de insulina del paciente y refresca la sesión
  /// cacheada — no hay GET dedicado, los valores viven en `PatientResponse`.
  Future<void> updateInsulinProfile({
    required double sensitivityFactor,
    required double carbRatio,
    required double targetGlucose,
  });
}
