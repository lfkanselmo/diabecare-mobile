import '../entities/active_session.dart';
import '../entities/device_api_key.dart';

/// Dominio 100% online, sin persistencia local. `suspendAccount`/
/// `deleteAccount` limpian la sesión local tras el éxito (la cuenta deja de
/// ser usable, igual que un logout forzado).
abstract interface class AccountRepository {
  Future<List<ActiveSession>> getActiveSessions();

  Future<void> logoutAllSessions();

  Future<void> suspendAccount();

  Future<void> deleteAccount();

  /// Descarga el JSON y lo comparte de inmediato (`share_plus`), igual
  /// patrón que el reporte PDF.
  Future<void> exportAndShareData();

  Future<GeneratedDeviceApiKey> generateDeviceApiKey(String label);

  Future<List<DeviceApiKey>> listDeviceApiKeys();

  Future<void> revokeDeviceApiKey(String keyId);
}
