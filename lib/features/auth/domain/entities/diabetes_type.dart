/// Debe coincidir exactamente con `DiabetesType.java` del backend — el valor
/// que viaja por la red es [wireValue], no el nombre del enum de Dart.
enum DiabetesType {
  type1('TYPE_1'),
  type2('TYPE_2'),
  gestational('GESTATIONAL'),
  lada('LADA'),
  mody('MODY');

  const DiabetesType(this.wireValue);

  final String wireValue;

  static DiabetesType fromWire(String value) =>
      values.firstWhere((e) => e.wireValue == value);
}
