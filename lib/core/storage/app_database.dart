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

@DriftDatabase(tables: [SyncCursors, GlucoseReadings])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(glucoseReadings);
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
