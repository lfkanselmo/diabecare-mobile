/// Debe coincidir exactamente con `DoseUnit.java` del backend.
enum DoseUnit {
  mg('MG'),
  ml('ML'),
  units('UNITS');

  const DoseUnit(this.wireValue);

  final String wireValue;

  static DoseUnit fromWire(String value) => values.firstWhere((e) => e.wireValue == value);
}
