/// Debe coincidir exactamente con `SymptomSeverity.java` del backend.
enum SymptomSeverity {
  mild('MILD'),
  moderate('MODERATE'),
  severe('SEVERE');

  const SymptomSeverity(this.wireValue);

  final String wireValue;

  static SymptomSeverity fromWire(String value) => values.firstWhere((e) => e.wireValue == value);
}
