import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/glucose/presentation/providers/glucose_providers.dart';
import 'sync_coordinator.dart';
import 'sync_service.dart';
import 'syncable_repository.dart';

part 'sync_providers.g.dart';

/// Cada dominio offline-first (glucosa es el primero, Fase 1) se agrega acá
/// a la lista de repositorios — el resto del motor no necesita cambios.
@Riverpod(keepAlive: true)
SyncService syncService(Ref ref) {
  return SyncService(
    repositories: [ref.watch(glucoseRepositoryProvider) as SyncableRepository<dynamic>],
  );
}

@Riverpod(keepAlive: true)
SyncCoordinator syncCoordinator(Ref ref) {
  final coordinator = SyncCoordinator(
    syncService: ref.watch(syncServiceProvider),
    pullers: [() => ref.watch(glucoseRepositoryProvider).pullChanges()],
  );
  coordinator.startWatchingConnectivity();
  ref.onDispose(coordinator.dispose);
  return coordinator;
}
