import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Bloqueo biométrico opcional al volver del background — capa adicional
/// que no existe en la web, justificada por tratarse de datos de salud en
/// un dispositivo que puede perderse o ser robado (ARCHITECTURE.md 3.2).
/// Apagado por defecto; el usuario lo activa explícitamente (el toggle en sí
/// vive en la pantalla de perfil, que llega en una fase posterior — este
/// servicio ya queda listo para que ese toggle solo tenga que llamar
/// [setEnabled]).
class BiometricLockService {
  BiometricLockService({LocalAuthentication? localAuth, FlutterSecureStorage? storage})
    : _localAuth = localAuth ?? LocalAuthentication(),
      _storage = storage ?? const FlutterSecureStorage();

  final LocalAuthentication _localAuth;
  final FlutterSecureStorage _storage;

  static const _enabledKey = 'dc_biometric_lock_enabled';

  Future<bool> isAvailable() async {
    final canCheck = await _localAuth.canCheckBiometrics;
    final isSupported = await _localAuth.isDeviceSupported();
    return canCheck && isSupported;
  }

  Future<bool> isEnabled() async => (await _storage.read(key: _enabledKey)) == 'true';

  Future<void> setEnabled(bool enabled) => _storage.write(key: _enabledKey, value: enabled.toString());

  /// Retorna false si el dispositivo no soporta biometría o si el usuario
  /// cancela/falla la autenticación — el llamador decide qué hacer en ambos
  /// casos (nunca lanza).
  Future<bool> authenticate({required String reason}) async {
    if (!await isAvailable()) return false;
    try {
      return await _localAuth.authenticate(localizedReason: reason, persistAcrossBackgrounding: true);
    } catch (_) {
      return false;
    }
  }
}
