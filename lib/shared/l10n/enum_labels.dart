import '../../core/l10n/app_localizations.dart';
import '../../features/admin/domain/entities/user_role.dart';
import '../../features/auth/domain/entities/biological_sex.dart';
import '../../features/auth/domain/entities/diabetes_type.dart';
import '../../features/glucose/domain/entities/glucose_unit.dart';
import '../../features/glucose/domain/entities/reading_type.dart';
import '../../features/medications/domain/entities/dose_unit.dart';
import '../../features/medications/domain/entities/medication_frequency.dart';
import '../../features/medications/domain/entities/medication_type.dart';
import '../../features/menstrual_cycle/domain/entities/cycle_symptom.dart';
import '../../features/menstrual_cycle/domain/entities/flow_intensity.dart';
import '../../features/menstrual_cycle/domain/entities/symptom_severity.dart';
import '../../features/vitals/domain/entities/exercise_intensity.dart';
import '../../features/vitals/domain/entities/exercise_type.dart';

/// Etiquetas traducidas para los catálogos clínicos que viajan como enum con
/// `wireValue`. Viven acá (no en `domain/entities/`) porque `AppLocalizations`
/// depende de Flutter — el dominio se mantiene Dart puro (ARCHITECTURE.md §2).
extension MedicationTypeLabel on MedicationType {
  String label(AppLocalizations l10n) => switch (this) {
    MedicationType.insulinBasal => l10n.medicationsTypeInsulinBasal,
    MedicationType.insulinBolus => l10n.medicationsTypeInsulinBolus,
    MedicationType.oral => l10n.medicationsTypeOral,
    MedicationType.injectable => l10n.medicationsTypeInjectable,
  };
}

extension DoseUnitLabel on DoseUnit {
  String label(AppLocalizations l10n) => switch (this) {
    DoseUnit.mg => l10n.medicationsDoseUnitMg,
    DoseUnit.ml => l10n.medicationsDoseUnitMl,
    DoseUnit.units => l10n.medicationsDoseUnitUnits,
  };
}

extension MedicationFrequencyLabel on MedicationFrequency {
  String label(AppLocalizations l10n) => switch (this) {
    MedicationFrequency.onceDaily => l10n.medicationsFrequencyOnceDaily,
    MedicationFrequency.twiceDaily => l10n.medicationsFrequencyTwiceDaily,
    MedicationFrequency.threeTimesDaily => l10n.medicationsFrequencyThreeTimesDaily,
    MedicationFrequency.withMeals => l10n.medicationsFrequencyWithMeals,
    MedicationFrequency.beforeMeals => l10n.medicationsFrequencyBeforeMeals,
    MedicationFrequency.atBedtime => l10n.medicationsFrequencyAtBedtime,
    MedicationFrequency.asNeeded => l10n.medicationsFrequencyAsNeeded,
  };
}

extension ExerciseTypeLabel on ExerciseType {
  String label(AppLocalizations l10n) => switch (this) {
    ExerciseType.walking => l10n.exerciseTypeWalking,
    ExerciseType.running => l10n.exerciseTypeRunning,
    ExerciseType.jogging => l10n.exerciseTypeJogging,
    ExerciseType.cycling => l10n.exerciseTypeCycling,
    ExerciseType.stationaryBike => l10n.exerciseTypeStationaryBike,
    ExerciseType.swimming => l10n.exerciseTypeSwimming,
    ExerciseType.waterAerobics => l10n.exerciseTypeWaterAerobics,
    ExerciseType.weightTraining => l10n.exerciseTypeWeightTraining,
    ExerciseType.calisthenics => l10n.exerciseTypeCalisthenics,
    ExerciseType.crossfit => l10n.exerciseTypeCrossfit,
    ExerciseType.yoga => l10n.exerciseTypeYoga,
    ExerciseType.pilates => l10n.exerciseTypePilates,
    ExerciseType.stretching => l10n.exerciseTypeStretching,
    ExerciseType.taiChi => l10n.exerciseTypeTaiChi,
    ExerciseType.football => l10n.exerciseTypeFootball,
    ExerciseType.basketball => l10n.exerciseTypeBasketball,
    ExerciseType.volleyball => l10n.exerciseTypeVolleyball,
    ExerciseType.tennis => l10n.exerciseTypeTennis,
    ExerciseType.padel => l10n.exerciseTypePadel,
    ExerciseType.baseball => l10n.exerciseTypeBaseball,
    ExerciseType.golf => l10n.exerciseTypeGolf,
    ExerciseType.dancing => l10n.exerciseTypeDancing,
    ExerciseType.zumba => l10n.exerciseTypeZumba,
    ExerciseType.aerobics => l10n.exerciseTypeAerobics,
    ExerciseType.hiking => l10n.exerciseTypeHiking,
    ExerciseType.climbing => l10n.exerciseTypeClimbing,
    ExerciseType.elliptical => l10n.exerciseTypeElliptical,
    ExerciseType.rowing => l10n.exerciseTypeRowing,
    ExerciseType.jumpingRope => l10n.exerciseTypeJumpingRope,
    ExerciseType.stairClimbing => l10n.exerciseTypeStairClimbing,
    ExerciseType.martialArts => l10n.exerciseTypeMartialArts,
    ExerciseType.boxing => l10n.exerciseTypeBoxing,
    ExerciseType.skating => l10n.exerciseTypeSkating,
    ExerciseType.skiing => l10n.exerciseTypeSkiing,
    ExerciseType.surfing => l10n.exerciseTypeSurfing,
    ExerciseType.householdChores => l10n.exerciseTypeHouseholdChores,
    ExerciseType.gardening => l10n.exerciseTypeGardening,
    ExerciseType.physicalTherapy => l10n.exerciseTypePhysicalTherapy,
    ExerciseType.other => l10n.exerciseTypeOther,
  };
}

extension ExerciseIntensityLabel on ExerciseIntensity {
  String label(AppLocalizations l10n) => switch (this) {
    ExerciseIntensity.low => l10n.exerciseIntensityLow,
    ExerciseIntensity.moderate => l10n.exerciseIntensityModerate,
    ExerciseIntensity.high => l10n.exerciseIntensityHigh,
  };
}

extension FlowIntensityLabel on FlowIntensity {
  String label(AppLocalizations l10n) => switch (this) {
    FlowIntensity.none => l10n.cycleFlowNone,
    FlowIntensity.spotting => l10n.cycleFlowSpotting,
    FlowIntensity.light => l10n.cycleFlowLight,
    FlowIntensity.moderate => l10n.cycleFlowModerate,
    FlowIntensity.heavy => l10n.cycleFlowHeavy,
    FlowIntensity.veryHeavy => l10n.cycleFlowVeryHeavy,
  };
}

extension CycleSymptomLabel on CycleSymptom {
  String label(AppLocalizations l10n) => switch (this) {
    CycleSymptom.cramps => l10n.cycleSymptomCramps,
    CycleSymptom.headache => l10n.cycleSymptomHeadache,
    CycleSymptom.migraine => l10n.cycleSymptomMigraine,
    CycleSymptom.fatigue => l10n.cycleSymptomFatigue,
    CycleSymptom.moodChanges => l10n.cycleSymptomMoodChanges,
    CycleSymptom.anxiety => l10n.cycleSymptomAnxiety,
    CycleSymptom.irritability => l10n.cycleSymptomIrritability,
    CycleSymptom.sadness => l10n.cycleSymptomSadness,
    CycleSymptom.bloating => l10n.cycleSymptomBloating,
    CycleSymptom.cravings => l10n.cycleSymptomCravings,
    CycleSymptom.appetiteIncrease => l10n.cycleSymptomAppetiteIncrease,
    CycleSymptom.appetiteDecrease => l10n.cycleSymptomAppetiteDecrease,
    CycleSymptom.breastTenderness => l10n.cycleSymptomBreastTenderness,
    CycleSymptom.sleepDifficulty => l10n.cycleSymptomSleepDifficulty,
    CycleSymptom.backPain => l10n.cycleSymptomBackPain,
    CycleSymptom.jointPain => l10n.cycleSymptomJointPain,
    CycleSymptom.nausea => l10n.cycleSymptomNausea,
    CycleSymptom.diarrhea => l10n.cycleSymptomDiarrhea,
    CycleSymptom.constipation => l10n.cycleSymptomConstipation,
    CycleSymptom.acne => l10n.cycleSymptomAcne,
    CycleSymptom.spotting => l10n.cycleSymptomSpotting,
    CycleSymptom.hotFlashes => l10n.cycleSymptomHotFlashes,
    CycleSymptom.dizziness => l10n.cycleSymptomDizziness,
    CycleSymptom.lowLibido => l10n.cycleSymptomLowLibido,
    CycleSymptom.highLibido => l10n.cycleSymptomHighLibido,
    CycleSymptom.brainFog => l10n.cycleSymptomBrainFog,
    CycleSymptom.clots => l10n.cycleSymptomClots,
  };
}

extension SymptomSeverityLabel on SymptomSeverity {
  String label(AppLocalizations l10n) => switch (this) {
    SymptomSeverity.mild => l10n.symptomSeverityMild,
    SymptomSeverity.moderate => l10n.symptomSeverityModerate,
    SymptomSeverity.severe => l10n.symptomSeveritySevere,
  };
}

extension DiabetesTypeLabel on DiabetesType {
  String label(AppLocalizations l10n) => switch (this) {
    DiabetesType.type1 => l10n.diabetesTypeType1,
    DiabetesType.type2 => l10n.diabetesTypeType2,
    DiabetesType.gestational => l10n.diabetesTypeGestational,
    DiabetesType.lada => l10n.diabetesTypeLada,
    DiabetesType.mody => l10n.diabetesTypeMody,
  };
}

extension BiologicalSexLabel on BiologicalSex {
  String label(AppLocalizations l10n) => switch (this) {
    BiologicalSex.female => l10n.biologicalSexFemale,
    BiologicalSex.male => l10n.biologicalSexMale,
    BiologicalSex.notSpecified => l10n.biologicalSexNotSpecified,
  };
}

extension GlucoseUnitLabel on GlucoseUnit {
  String label(AppLocalizations l10n) => switch (this) {
    GlucoseUnit.mgDl => l10n.glucoseUnitMgDl,
    GlucoseUnit.mmolL => l10n.glucoseUnitMmolL,
  };
}

extension ReadingTypeLabel on ReadingType {
  String label(AppLocalizations l10n) => switch (this) {
    ReadingType.fasting => l10n.readingTypeFasting,
    ReadingType.preMeal => l10n.readingTypePreMeal,
    ReadingType.postMeal => l10n.readingTypePostMeal,
    ReadingType.bedtime => l10n.readingTypeBedtime,
    ReadingType.random => l10n.readingTypeRandom,
  };
}

extension UserRoleLabel on UserRole {
  String label(AppLocalizations l10n) => switch (this) {
    UserRole.patient => l10n.userRolePatient,
    UserRole.admin => l10n.userRoleAdmin,
  };
}
