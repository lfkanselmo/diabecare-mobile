/// Debe coincidir exactamente con `BmiCategory.java` del backend. Siempre
/// calculado por el servidor — nunca se establece del lado cliente.
enum BmiCategory {
  underweight('UNDERWEIGHT'),
  normal('NORMAL'),
  overweight('OVERWEIGHT'),
  obese('OBESE');

  const BmiCategory(this.wireValue);

  final String wireValue;

  static BmiCategory fromWire(String value) => values.firstWhere((e) => e.wireValue == value);
}
