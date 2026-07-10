/// Debe coincidir exactamente con `BiologicalSex.java` del backend — el valor
/// que viaja por la red es [wireValue], no el nombre del enum de Dart.
enum BiologicalSex {
  female('FEMALE'),
  male('MALE'),
  notSpecified('NOT_SPECIFIED');

  const BiologicalSex(this.wireValue);

  final String wireValue;

  static BiologicalSex fromWire(String value) =>
      values.firstWhere((e) => e.wireValue == value);
}
