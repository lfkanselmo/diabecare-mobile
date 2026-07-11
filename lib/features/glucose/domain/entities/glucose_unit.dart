/// Debe coincidir exactamente con `GlucoseUnit.java` del backend.
enum GlucoseUnit {
  mgDl('MG_DL'),
  mmolL('MMOL_L');

  const GlucoseUnit(this.wireValue);

  final String wireValue;

  static GlucoseUnit fromWire(String value) => values.firstWhere((e) => e.wireValue == value);
}
