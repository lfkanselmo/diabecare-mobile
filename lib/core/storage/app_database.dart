import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Cursor de sincronización incremental por recurso (`glucose`, `meals`...) —
/// infraestructura genérica del motor de sync (ARCHITECTURE.md sección 4.4).
/// Las tablas de dominio (`GlucoseReadings`, etc.) llegan en Fase 1+ y se
/// agregan a `@DriftDatabase(tables: [...])` sin fricción, gracias a que la
/// infraestructura de migraciones ya queda lista acá.
class SyncCursors extends Table {
  TextColumn get resource => text()();
  DateTimeColumn get lastSyncedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {resource};
}

@DriftDatabase(tables: [SyncCursors])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'diabecare.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
