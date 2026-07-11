// DTOs de red — mirror exacto de `DeviceApiKeyController`.

class DeviceApiKeyResponseDto {
  DeviceApiKeyResponseDto({
    required this.id,
    required this.label,
    required this.createdAt,
    required this.revoked,
    this.lastUsedAt,
  });

  factory DeviceApiKeyResponseDto.fromJson(Map<String, dynamic> json) => DeviceApiKeyResponseDto(
    id: json['id'] as String,
    label: json['label'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    lastUsedAt: json['lastUsedAt'] == null ? null : DateTime.parse(json['lastUsedAt'] as String),
    revoked: json['revoked'] as bool,
  );

  final String id;
  final String label;
  final DateTime createdAt;
  final DateTime? lastUsedAt;
  final bool revoked;
}

class GeneratedDeviceApiKeyResponseDto {
  GeneratedDeviceApiKeyResponseDto({
    required this.id,
    required this.rawKey,
    required this.label,
    required this.createdAt,
  });

  factory GeneratedDeviceApiKeyResponseDto.fromJson(Map<String, dynamic> json) => GeneratedDeviceApiKeyResponseDto(
    id: json['id'] as String,
    rawKey: json['rawKey'] as String,
    label: json['label'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  final String id;
  final String rawKey;
  final String label;
  final DateTime createdAt;
}
