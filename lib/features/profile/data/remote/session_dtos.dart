// DTO de red — mirror exacto de `AuthController.getActiveSessions`.

class ActiveSessionResponseDto {
  ActiveSessionResponseDto({
    required this.id,
    required this.deviceLabel,
    required this.lastUsedAt,
    required this.createdAt,
  });

  factory ActiveSessionResponseDto.fromJson(Map<String, dynamic> json) => ActiveSessionResponseDto(
    id: json['id'] as String,
    deviceLabel: json['deviceLabel'] as String,
    lastUsedAt: DateTime.parse(json['lastUsedAt'] as String),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  final String id;
  final String deviceLabel;
  final DateTime lastUsedAt;
  final DateTime createdAt;
}
