/// Debe coincidir exactamente con `ReadingType.java` del backend.
enum ReadingType {
  fasting('FASTING'),
  preMeal('PRE_MEAL'),
  postMeal('POST_MEAL'),
  bedtime('BEDTIME'),
  random('RANDOM');

  const ReadingType(this.wireValue);

  final String wireValue;

  static ReadingType fromWire(String value) => values.firstWhere((e) => e.wireValue == value);
}
