class DeviceApiKey {
  const DeviceApiKey({
    required this.id,
    required this.label,
    required this.createdAt,
    required this.revoked,
    this.lastUsedAt,
  });

  final String id;
  final String label;
  final DateTime createdAt;
  final DateTime? lastUsedAt;
  final bool revoked;
}

/// Es la única vez que se expone `rawKey` — a partir de acá solo se guarda
/// su hash en el servidor (ver `GeneratedDeviceApiKeyResponse` del backend).
class GeneratedDeviceApiKey {
  const GeneratedDeviceApiKey({
    required this.id,
    required this.rawKey,
    required this.label,
    required this.createdAt,
  });

  final String id;
  final String rawKey;
  final String label;
  final DateTime createdAt;
}
