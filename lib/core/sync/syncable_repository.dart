import 'sync_status.dart';

/// Un cambio local pendiente de sincronizar con el backend.
class PendingChange<T> {
  const PendingChange({required this.id, required this.status, required this.payload});

  final String id;

  /// Siempre `pendingCreate`/`pendingUpdate`/`pendingDelete` — [SyncService]
  /// no espera otros valores acá.
  final SyncStatus status;

  final T payload;
}

/// Interfaz que cada repositorio de dominio (glucosa, comidas... desde Fase 1)
/// implementa para participar del motor de sync genérico. `id` es siempre el
/// UUID generado por el cliente (ver `createWithId` del backend) — nunca hay
/// conflicto de creación por construcción.
abstract interface class SyncableRepository<T> {
  String get resourceName;

  Future<List<PendingChange<T>>> getPending();

  Future<void> pushCreate(T payload);

  Future<void> pushUpdate(T payload);

  Future<void> pushDelete(String id);

  Future<void> markSynced(String id, DateTime serverUpdatedAt);

  /// Nunca se descarta el registro — solo se marca visible en una pantalla
  /// de "elementos con problemas de sincronización" (ARCHITECTURE.md 4.3).
  Future<void> markSyncError(String id, String message);
}
