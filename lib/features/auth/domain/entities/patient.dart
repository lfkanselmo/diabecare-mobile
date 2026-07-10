import 'biological_sex.dart';
import 'diabetes_type.dart';

/// Mirror de `PatientResponse` del backend (`diabecare-api`).
class Patient {
  const Patient({
    required this.patientId,
    required this.fullName,
    required this.dateOfBirth,
    required this.age,
    required this.diabetesType,
    required this.diagnosisDate,
    required this.heightCm,
    required this.targetGlucoseMin,
    required this.targetGlucoseMax,
    required this.activityLevel,
    required this.preferredGlucoseUnit,
    required this.biologicalSex,
    this.dailyCalorieGoal,
    this.insulinSensitivityFactor,
    this.insulinToCarbRatio,
    this.targetGlucoseForCorrection,
  });

  final String patientId;
  final String fullName;
  final DateTime dateOfBirth;
  final int age;
  final DiabetesType diabetesType;
  final DateTime diagnosisDate;
  final double heightCm;
  final double targetGlucoseMin;
  final double targetGlucoseMax;
  final String activityLevel;
  final String preferredGlucoseUnit;
  final BiologicalSex biologicalSex;
  final int? dailyCalorieGoal;
  final double? insulinSensitivityFactor;
  final double? insulinToCarbRatio;
  final double? targetGlucoseForCorrection;

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      patientId: json['patientId'] as String,
      fullName: json['fullName'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      age: json['age'] as int,
      diabetesType: DiabetesType.fromWire(json['diabetesType'] as String),
      diagnosisDate: DateTime.parse(json['diagnosisDate'] as String),
      heightCm: (json['heightCm'] as num).toDouble(),
      targetGlucoseMin: (json['targetGlucoseMin'] as num).toDouble(),
      targetGlucoseMax: (json['targetGlucoseMax'] as num).toDouble(),
      activityLevel: json['activityLevel'] as String,
      preferredGlucoseUnit: json['preferredGlucoseUnit'] as String,
      biologicalSex: BiologicalSex.fromWire(json['biologicalSex'] as String),
      dailyCalorieGoal: json['dailyCalorieGoal'] as int?,
      insulinSensitivityFactor: (json['insulinSensitivityFactor'] as num?)?.toDouble(),
      insulinToCarbRatio: (json['insulinToCarbRatio'] as num?)?.toDouble(),
      targetGlucoseForCorrection: (json['targetGlucoseForCorrection'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'patientId': patientId,
    'fullName': fullName,
    'dateOfBirth': _isoDate(dateOfBirth),
    'age': age,
    'diabetesType': diabetesType.wireValue,
    'diagnosisDate': _isoDate(diagnosisDate),
    'heightCm': heightCm,
    'targetGlucoseMin': targetGlucoseMin,
    'targetGlucoseMax': targetGlucoseMax,
    'activityLevel': activityLevel,
    'preferredGlucoseUnit': preferredGlucoseUnit,
    'biologicalSex': biologicalSex.wireValue,
    'dailyCalorieGoal': dailyCalorieGoal,
    'insulinSensitivityFactor': insulinSensitivityFactor,
    'insulinToCarbRatio': insulinToCarbRatio,
    'targetGlucoseForCorrection': targetGlucoseForCorrection,
  };
}

String _isoDate(DateTime date) => date.toIso8601String().split('T').first;
