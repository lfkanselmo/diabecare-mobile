/// Estado de sincronización de un registro local (ARCHITECTURE.md 4.2).
/// `syncError` nunca se descarta en silencio — se expone en una pantalla de
/// "elementos con problemas de sincronización".
enum SyncStatus { synced, pendingCreate, pendingUpdate, pendingDelete, syncError }
