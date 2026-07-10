/// URL base de `diabecare-api`. Override en build/run con
/// `--dart-define=API_URL=https://...`.
class Env {
  Env._();

  static const apiUrl = String.fromEnvironment('API_URL', defaultValue: _devDefault);

  // 10.0.2.2 es el alias que usa el emulador de Android para llegar al
  // localhost de la máquina host — "localhost" a secas apuntaría al propio
  // emulador. En iOS el simulador sí comparte el localhost del host, pero no
  // hay forma de compilar/probar iOS desde Windows de todas formas.
  static const _devDefault = 'http://10.0.2.2:8080/api/v1';
}
