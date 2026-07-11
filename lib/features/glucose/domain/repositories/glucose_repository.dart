import '../entities/glucose_reading.dart';
import '../entities/glucose_stats.dart';
import '../entities/glucose_unit.dart';
import '../entities/reading_type.dart';

/// `watchReadings`/`getLatest` leen siempre de la caché local (Drift) —
/// nunca directo de red, así reflejan de inmediato las lecturas pendientes
/// de sincronizar. `getStats`/`getAgpProfile` son agregaciones que solo el
/// servidor puede calcular sobre todo el histórico — red-first, sin
/// contraparte local (igual de alcance que la web, ver ARCHITECTURE.md §4.6).
abstract interface class GlucoseRepository {
  Stream<List<GlucoseReading>> watchReadings({required DateTime from, required DateTime to});

  Future<GlucoseReading?> getLatest();

  /// Genera el ID localmente, inserta con `pendingCreate` y encola el envío
  /// al backend (el `SyncService` de Fase 0 se encarga del resto).
  Future<GlucoseReading> register({
    required double value,
    required GlucoseUnit unit,
    required ReadingType readingType,
    required DateTime measuredAt,
    String? notes,
    String? deviceSource,
  });

  Future<void> delete(String id);

  Future<GlucoseStats> getStats({required DateTime from, required DateTime to});

  Future<List<AgpBucket>> getAgpProfile({required DateTime from, required DateTime to});

  /// Trae del backend todo lo creado/modificado desde el último cursor
  /// (`/sync?since=`) y hace upsert local — ver ARCHITECTURE.md §4.4. Al ser
  /// la única fuente de lectura de historial (no hay llamada directa a
  /// `/history`), la primera sincronización (`since` nulo) ya trae todo el
  /// histórico del paciente.
  Future<void> pullChanges();
}
