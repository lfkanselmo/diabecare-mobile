/// Debe coincidir exactamente con `GlucoseStatus.java` del backend. Siempre
/// lo computa el servidor — nunca se deriva en el cliente, ni para lecturas
/// pendientes de sincronizar (quedan sin `status` hasta la respuesta real).
enum GlucoseStatus {
  criticallyLow('CRITICALLY_LOW'),
  low('LOW'),
  normal('NORMAL'),
  high('HIGH'),
  criticallyHigh('CRITICALLY_HIGH');

  const GlucoseStatus(this.wireValue);

  final String wireValue;

  static GlucoseStatus fromWire(String value) => values.firstWhere((e) => e.wireValue == value);
}
