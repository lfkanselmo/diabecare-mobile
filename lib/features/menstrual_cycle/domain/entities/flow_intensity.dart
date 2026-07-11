/// Debe coincidir exactamente con `FlowIntensity.java` del backend.
enum FlowIntensity {
  none('NONE'),
  spotting('SPOTTING'),
  light('LIGHT'),
  moderate('MODERATE'),
  heavy('HEAVY'),
  veryHeavy('VERY_HEAVY');

  const FlowIntensity(this.wireValue);

  final String wireValue;

  static FlowIntensity fromWire(String value) => values.firstWhere((e) => e.wireValue == value);
}
