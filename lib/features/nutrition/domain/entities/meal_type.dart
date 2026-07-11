/// Debe coincidir exactamente con `MealType.java` del backend.
enum MealType {
  breakfast('BREAKFAST'),
  lunch('LUNCH'),
  dinner('DINNER'),
  snack('SNACK');

  const MealType(this.wireValue);

  final String wireValue;

  static MealType fromWire(String value) => values.firstWhere((e) => e.wireValue == value);
}
