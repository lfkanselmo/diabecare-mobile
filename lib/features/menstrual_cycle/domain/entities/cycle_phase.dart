/// Debe coincidir exactamente con `CyclePhase.java` del backend.
enum CyclePhase {
  menstruation('MENSTRUATION'),
  follicular('FOLLICULAR'),
  ovulation('OVULATION'),
  lutealEarly('LUTEAL_EARLY'),
  lutealLate('LUTEAL_LATE');

  const CyclePhase(this.wireValue);

  final String wireValue;

  static CyclePhase fromWire(String value) => values.firstWhere((e) => e.wireValue == value);
}
