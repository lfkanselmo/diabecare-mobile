/// Debe coincidir exactamente con `MedicationFrequency.java` del backend.
/// Los recordatorios son 100% push server-side
/// (`MedicationReminderTimeResolver`) — no hay CRUD de horarios en el
/// cliente, solo se muestra la frecuencia.
enum MedicationFrequency {
  onceDaily('ONCE_DAILY'),
  twiceDaily('TWICE_DAILY'),
  threeTimesDaily('THREE_TIMES_DAILY'),
  withMeals('WITH_MEALS'),
  beforeMeals('BEFORE_MEALS'),
  atBedtime('AT_BEDTIME'),
  asNeeded('AS_NEEDED');

  const MedicationFrequency(this.wireValue);

  final String wireValue;

  static MedicationFrequency fromWire(String value) => values.firstWhere((e) => e.wireValue == value);
}
