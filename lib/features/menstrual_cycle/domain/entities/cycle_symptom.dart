/// Debe coincidir exactamente con `CycleSymptom.java` del backend.
enum CycleSymptom {
  cramps('CRAMPS'),
  headache('HEADACHE'),
  migraine('MIGRAINE'),
  fatigue('FATIGUE'),
  moodChanges('MOOD_CHANGES'),
  anxiety('ANXIETY'),
  irritability('IRRITABILITY'),
  sadness('SADNESS'),
  bloating('BLOATING'),
  cravings('CRAVINGS'),
  appetiteIncrease('APPETITE_INCREASE'),
  appetiteDecrease('APPETITE_DECREASE'),
  breastTenderness('BREAST_TENDERNESS'),
  sleepDifficulty('SLEEP_DIFFICULTY'),
  backPain('BACK_PAIN'),
  jointPain('JOINT_PAIN'),
  nausea('NAUSEA'),
  diarrhea('DIARRHEA'),
  constipation('CONSTIPATION'),
  acne('ACNE'),
  spotting('SPOTTING'),
  hotFlashes('HOT_FLASHES'),
  dizziness('DIZZINESS'),
  lowLibido('LOW_LIBIDO'),
  highLibido('HIGH_LIBIDO'),
  brainFog('BRAIN_FOG'),
  clots('CLOTS');

  const CycleSymptom(this.wireValue);

  final String wireValue;

  static CycleSymptom fromWire(String value) => values.firstWhere((e) => e.wireValue == value);
}
