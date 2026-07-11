/// Debe coincidir exactamente con `ExerciseIntensity.java` del backend.
enum ExerciseIntensity {
  low('LOW'),
  moderate('MODERATE'),
  high('HIGH');

  const ExerciseIntensity(this.wireValue);

  final String wireValue;

  static ExerciseIntensity fromWire(String value) => values.firstWhere((e) => e.wireValue == value);
}
