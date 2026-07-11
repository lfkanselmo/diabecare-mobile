/// Debe coincidir exactamente con `ExerciseType.java` del backend.
enum ExerciseType {
  walking('WALKING'),
  running('RUNNING'),
  jogging('JOGGING'),
  cycling('CYCLING'),
  stationaryBike('STATIONARY_BIKE'),
  swimming('SWIMMING'),
  waterAerobics('WATER_AEROBICS'),
  weightTraining('WEIGHT_TRAINING'),
  calisthenics('CALISTHENICS'),
  crossfit('CROSSFIT'),
  yoga('YOGA'),
  pilates('PILATES'),
  stretching('STRETCHING'),
  taiChi('TAI_CHI'),
  football('FOOTBALL'),
  basketball('BASKETBALL'),
  volleyball('VOLLEYBALL'),
  tennis('TENNIS'),
  padel('PADEL'),
  baseball('BASEBALL'),
  golf('GOLF'),
  dancing('DANCING'),
  zumba('ZUMBA'),
  aerobics('AEROBICS'),
  hiking('HIKING'),
  climbing('CLIMBING'),
  elliptical('ELLIPTICAL'),
  rowing('ROWING'),
  jumpingRope('JUMPING_ROPE'),
  stairClimbing('STAIR_CLIMBING'),
  martialArts('MARTIAL_ARTS'),
  boxing('BOXING'),
  skating('SKATING'),
  skiing('SKIING'),
  surfing('SURFING'),
  householdChores('HOUSEHOLD_CHORES'),
  gardening('GARDENING'),
  physicalTherapy('PHYSICAL_THERAPY'),
  other('OTHER');

  const ExerciseType(this.wireValue);

  final String wireValue;

  static ExerciseType fromWire(String value) => values.firstWhere((e) => e.wireValue == value);
}
