import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Cursor de sincronización incremental por recurso (`glucose`, `meals`...) —
/// infraestructura genérica del motor de sync (ARCHITECTURE.md sección 4.4).
class SyncCursors extends Table {
  TextColumn get resource => text()();
  DateTimeColumn get lastSyncedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {resource};
}

/// Esquema exacto de ARCHITECTURE.md §4.2: columnas de dominio + las 3
/// columnas de sync que toda tabla offline-first agrega (`syncStatus`,
/// `localUpdatedAt`, `serverUpdatedAt`). Primer dominio conectado al motor
/// de sync (Fase 1). `@DataClassName` evita que Drift genere una clase de
/// fila llamada `GlucoseReading`, que ya es el nombre de la entidad de
/// dominio en `features/glucose/domain/entities/`.
@DataClassName('GlucoseReadingRow')
class GlucoseReadings extends Table {
  TextColumn get id => text()();
  RealColumn get value => real()();
  TextColumn get unit => text()();
  TextColumn get readingType => text()();
  TextColumn get status => text().nullable()();
  DateTimeColumn get measuredAt => dateTime()();
  TextColumn get notes => text().nullable()();
  TextColumn get deviceSource => text().nullable()();

  TextColumn get syncStatus => text()();
  DateTimeColumn get localUpdatedAt => dateTime()();
  DateTimeColumn get serverUpdatedAt => dateTime().nullable()();
  TextColumn get syncErrorMessage => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Comidas (Fase 2). `itemsJson` serializa la lista de `MealItem` — los items
/// nunca se leen/escriben independientes de su comida, no justifica una tabla
/// relacional aparte (ver plan de Fase 2).
@DataClassName('MealEntryRow')
class MealEntries extends Table {
  TextColumn get id => text()();
  TextColumn get mealType => text()();
  DateTimeColumn get consumedAt => dateTime()();
  TextColumn get notes => text().nullable()();
  TextColumn get itemsJson => text()();
  RealColumn get totalCalories => real().nullable()();
  RealColumn get totalCarbohydrates => real().nullable()();
  RealColumn get totalProteins => real().nullable()();
  RealColumn get totalFats => real().nullable()();

  TextColumn get syncStatus => text()();
  DateTimeColumn get localUpdatedAt => dateTime()();
  DateTimeColumn get serverUpdatedAt => dateTime().nullable()();
  TextColumn get syncErrorMessage => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Signos vitales (Fase 2). `bmi`/`bmiCategory` son calculados por el
/// servidor — nulos hasta que el registro se sincroniza.
@DataClassName('VitalSignRow')
class VitalSigns extends Table {
  TextColumn get id => text()();
  RealColumn get weightKg => real().nullable()();
  RealColumn get heightCm => real().nullable()();
  IntColumn get systolicBp => integer().nullable()();
  IntColumn get diastolicBp => integer().nullable()();
  IntColumn get heartRate => integer().nullable()();
  RealColumn get hba1c => real().nullable()();
  DateTimeColumn get measuredAt => dateTime()();
  TextColumn get notes => text().nullable()();
  RealColumn get bmi => real().nullable()();
  TextColumn get bmiCategory => text().nullable()();

  TextColumn get syncStatus => text()();
  DateTimeColumn get localUpdatedAt => dateTime()();
  DateTimeColumn get serverUpdatedAt => dateTime().nullable()();
  TextColumn get syncErrorMessage => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Ejercicio (Fase 2). `caloriesBurned` puede venir del cliente (override
/// manual) o quedar nulo hasta que el servidor lo estime (ver toggle
/// manual/automático de la pantalla de registro).
@DataClassName('ExerciseLogRow')
class ExerciseLogs extends Table {
  TextColumn get id => text()();
  TextColumn get exerciseType => text()();
  TextColumn get intensity => text()();
  IntColumn get durationMinutes => integer()();
  RealColumn get caloriesBurned => real().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get performedAt => dateTime()();

  TextColumn get syncStatus => text()();
  DateTimeColumn get localUpdatedAt => dateTime()();
  DateTimeColumn get serverUpdatedAt => dateTime().nullable()();
  TextColumn get syncErrorMessage => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Medicamentos (Fase 2). `active` por defecto `true` — se desactiva
/// (nunca se borra) vía `DELETE /medications/{patientId}/{medicationId}`.
@DataClassName('MedicationRow')
class Medications extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  RealColumn get dose => real()();
  TextColumn get doseUnit => text()();
  TextColumn get frequency => text()();
  DateTimeColumn get startDate => dateTime().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  TextColumn get notes => text().nullable()();

  TextColumn get syncStatus => text()();
  DateTimeColumn get localUpdatedAt => dateTime()();
  DateTimeColumn get serverUpdatedAt => dateTime().nullable()();
  TextColumn get syncErrorMessage => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [SyncCursors, GlucoseReadings, MealEntries, VitalSigns, ExerciseLogs, Medications],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(glucoseReadings);
      }
      if (from < 3) {
        await m.createTable(mealEntries);
        await m.createTable(vitalSigns);
        await m.createTable(exerciseLogs);
        await m.createTable(medications);
      }
    },
  );

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'diabecare.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
