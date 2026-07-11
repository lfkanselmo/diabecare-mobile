/// Debe coincidir exactamente con `MedicationType.java` del backend.
enum MedicationType {
  insulinBasal('INSULIN_BASAL'),
  insulinBolus('INSULIN_BOLUS'),
  oral('ORAL'),
  injectable('INJECTABLE');

  const MedicationType(this.wireValue);

  final String wireValue;

  static MedicationType fromWire(String value) => values.firstWhere((e) => e.wireValue == value);
}
