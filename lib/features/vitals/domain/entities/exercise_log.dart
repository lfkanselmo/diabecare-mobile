import '../../../../core/sync/sync_status.dart';
import 'exercise_intensity.dart';
import 'exercise_type.dart';

/// `caloriesBurned` puede venir de un override manual del usuario o quedar
/// nulo hasta que el servidor lo estime (toggle manual/automático en la
/// pantalla de registro — no hay estimación client-side, ver plan de Fase 2).
class ExerciseLog {
  const ExerciseLog({
    required this.id,
    required this.exerciseType,
    required this.intensity,
    required this.durationMinutes,
    required this.performedAt,
    required this.syncStatus,
    this.caloriesBurned,
    this.notes,
    this.updatedAt,
  });

  final String id;
  final ExerciseType exerciseType;
  final ExerciseIntensity intensity;
  final int durationMinutes;
  final DateTime performedAt;
  final SyncStatus syncStatus;
  final double? caloriesBurned;
  final String? notes;
  final DateTime? updatedAt;
}
