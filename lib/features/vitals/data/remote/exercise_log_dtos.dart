// DTOs de red — mirror exacto de `ExerciseController`. `performedAt` viaja
// como String tal cual el backend (ver `ExerciseController.toResponse`).

class ExerciseLogResponseDto {
  ExerciseLogResponseDto({
    required this.exerciseId,
    required this.exerciseType,
    required this.intensity,
    required this.durationMinutes,
    required this.performedAt,
    this.caloriesBurned,
    this.notes,
    this.updatedAt,
  });

  factory ExerciseLogResponseDto.fromJson(Map<String, dynamic> json) => ExerciseLogResponseDto(
    exerciseId: json['exerciseId'] as String,
    exerciseType: json['exerciseType'] as String,
    intensity: json['intensity'] as String,
    durationMinutes: json['durationMinutes'] as int,
    caloriesBurned: (json['caloriesBurned'] as num?)?.toDouble(),
    notes: json['notes'] as String?,
    performedAt: json['performedAt'] as String,
    updatedAt: json['updatedAt'] == null ? null : DateTime.parse(json['updatedAt'] as String),
  );

  final String exerciseId;
  final String exerciseType;
  final String intensity;
  final int durationMinutes;
  final double? caloriesBurned;
  final String? notes;
  final String performedAt;
  final DateTime? updatedAt;
}
