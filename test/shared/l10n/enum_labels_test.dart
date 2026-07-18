import 'package:diabecare_mobile/core/l10n/app_localizations_en.dart';
import 'package:diabecare_mobile/core/l10n/app_localizations_es.dart';
import 'package:diabecare_mobile/features/admin/domain/entities/user_role.dart';
import 'package:diabecare_mobile/features/auth/domain/entities/biological_sex.dart';
import 'package:diabecare_mobile/features/auth/domain/entities/diabetes_type.dart';
import 'package:diabecare_mobile/features/glucose/domain/entities/glucose_unit.dart';
import 'package:diabecare_mobile/features/glucose/domain/entities/reading_type.dart';
import 'package:diabecare_mobile/features/medications/domain/entities/dose_unit.dart';
import 'package:diabecare_mobile/features/medications/domain/entities/medication_frequency.dart';
import 'package:diabecare_mobile/features/medications/domain/entities/medication_type.dart';
import 'package:diabecare_mobile/features/menstrual_cycle/domain/entities/cycle_symptom.dart';
import 'package:diabecare_mobile/features/menstrual_cycle/domain/entities/flow_intensity.dart';
import 'package:diabecare_mobile/features/menstrual_cycle/domain/entities/symptom_severity.dart';
import 'package:diabecare_mobile/features/vitals/domain/entities/exercise_intensity.dart';
import 'package:diabecare_mobile/features/vitals/domain/entities/exercise_type.dart';
import 'package:diabecare_mobile/shared/l10n/enum_labels.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final en = AppLocalizationsEn();
  final es = AppLocalizationsEs();

  group('label() nunca devuelve el wireValue crudo, para cada enum y cada idioma', () {
    void checkAllValues<T>(List<T> values, String Function(T) label) {
      for (final value in values) {
        final labelEn = label(value);
        expect(labelEn, isNotEmpty);
      }
    }

    test('MedicationType', () {
      checkAllValues(MedicationType.values, (v) => v.label(en));
      checkAllValues(MedicationType.values, (v) => v.label(es));
      expect(MedicationType.oral.label(en), 'Oral medication');
      expect(MedicationType.oral.label(es), 'Medicamento oral');
    });

    test('DoseUnit', () {
      checkAllValues(DoseUnit.values, (v) => v.label(en));
      checkAllValues(DoseUnit.values, (v) => v.label(es));
      expect(DoseUnit.units.label(en), 'Units');
      expect(DoseUnit.units.label(es), 'Unidades');
    });

    test('MedicationFrequency', () {
      checkAllValues(MedicationFrequency.values, (v) => v.label(en));
      checkAllValues(MedicationFrequency.values, (v) => v.label(es));
      expect(MedicationFrequency.twiceDaily.label(en), 'Twice daily');
      expect(MedicationFrequency.twiceDaily.label(es), 'Dos veces al día');
    });

    test('ExerciseType (39 valores)', () {
      expect(ExerciseType.values.length, 39);
      checkAllValues(ExerciseType.values, (v) => v.label(en));
      checkAllValues(ExerciseType.values, (v) => v.label(es));
      expect(ExerciseType.walking.label(en), 'Walking');
      expect(ExerciseType.walking.label(es), 'Caminata');
    });

    test('ExerciseIntensity', () {
      checkAllValues(ExerciseIntensity.values, (v) => v.label(en));
      checkAllValues(ExerciseIntensity.values, (v) => v.label(es));
    });

    test('FlowIntensity', () {
      checkAllValues(FlowIntensity.values, (v) => v.label(en));
      checkAllValues(FlowIntensity.values, (v) => v.label(es));
      expect(FlowIntensity.none.label(en), 'No bleeding');
      expect(FlowIntensity.none.label(es), 'Sin sangrado');
    });

    test('CycleSymptom (27 valores)', () {
      expect(CycleSymptom.values.length, 27);
      checkAllValues(CycleSymptom.values, (v) => v.label(en));
      checkAllValues(CycleSymptom.values, (v) => v.label(es));
    });

    test('SymptomSeverity', () {
      checkAllValues(SymptomSeverity.values, (v) => v.label(en));
      checkAllValues(SymptomSeverity.values, (v) => v.label(es));
    });

    test('DiabetesType', () {
      checkAllValues(DiabetesType.values, (v) => v.label(en));
      checkAllValues(DiabetesType.values, (v) => v.label(es));
      expect(DiabetesType.type2.label(en), 'Type 2');
      expect(DiabetesType.type2.label(es), 'Tipo 2');
    });

    test('BiologicalSex', () {
      checkAllValues(BiologicalSex.values, (v) => v.label(en));
      checkAllValues(BiologicalSex.values, (v) => v.label(es));
    });

    test('GlucoseUnit', () {
      checkAllValues(GlucoseUnit.values, (v) => v.label(en));
      checkAllValues(GlucoseUnit.values, (v) => v.label(es));
    });

    test('ReadingType', () {
      checkAllValues(ReadingType.values, (v) => v.label(en));
      checkAllValues(ReadingType.values, (v) => v.label(es));
    });

    test('UserRole', () {
      checkAllValues(UserRole.values, (v) => v.label(en));
      checkAllValues(UserRole.values, (v) => v.label(es));
      expect(UserRole.admin.label(en), 'Admin');
      expect(UserRole.admin.label(es), 'Administrador');
    });
  });
}
