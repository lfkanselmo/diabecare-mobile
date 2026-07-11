import '../entities/exercise_intensity.dart';
import '../entities/exercise_log.dart';
import '../entities/exercise_type.dart';

abstract interface class ExerciseLogRepository {
  Stream<List<ExerciseLog>> watchLogs({required DateTime from, required DateTime to});

  /// `caloriesBurnedOverride` nulo deja que el servidor lo estime por MET —
  /// no hay estimación client-side antes de enviar (ver plan de Fase 2).
  Future<ExerciseLog> register({
    required ExerciseType exerciseType,
    required ExerciseIntensity intensity,
    required int durationMinutes,
    required DateTime performedAt,
    String? notes,
    double? caloriesBurnedOverride,
  });

  Future<void> pullChanges();
}
